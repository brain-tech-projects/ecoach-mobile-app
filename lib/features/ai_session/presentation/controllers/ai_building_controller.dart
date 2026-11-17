import 'dart:async';

import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';

/// "Building your session": ticks 4 steps one by one, then opens the result.
/// Route arguments: the request text (String).
class AiBuildingController extends GetxController {
  static const Duration _step = Duration(milliseconds: 1100);

  final String request = Get.arguments is String ? Get.arguments as String : '';

  /// Steps already finished (0..4). The step at this index is "active".
  final RxInt done = 0.obs;
  late final List<String> steps;
  bool _alive = true;

  @override
  void onInit() {
    super.onInit();
    ensureAiSessionRepository();
    const p = AiSessionRepository.profile;
    steps = <String>[
      'Understanding your request',
      'Matching drills to ${p.positions.join(' and ')}',
      'Choosing drills suitable for age ${p.age.split(' ').first}',
      'Picking 4 drills from the approved eCoach library',
    ];
  }

  @override
  void onReady() {
    super.onReady();
    _run();
  }

  Future<void> _run() async {
    try {
      final build = Get.find<AiSessionRepository>().buildSession(request);
      for (var i = 0; i < steps.length; i++) {
        await Future<void>.delayed(_step);
        if (!_alive) return;
        done.value = i + 1;
      }
      final AiSession session = await build;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (_alive) Get.offNamed<void>(AppRoutes.aiResult, arguments: session);
    } catch (e, st) {
      AppLogger.error('AI build failed', error: e, stackTrace: st);
      if (_alive) Get.back<void>();
    }
  }

  @override
  void onClose() {
    _alive = false;
    super.onClose();
  }
}
