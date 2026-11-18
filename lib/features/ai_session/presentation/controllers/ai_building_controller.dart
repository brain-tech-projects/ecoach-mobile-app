import 'dart:async';

import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
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
    final p = AiSessionRepository.profile;
    steps = <String>[
      'Understanding your request',
      p.positions.isEmpty ? 'Matching drills to your position' : 'Matching drills to ${p.positions.join(' and ')}',
      p.age.isEmpty ? 'Choosing drills suitable for your age' : 'Choosing drills suitable for age ${p.age.split(' ').first}',
      'Picking 4 drills from the approved eCoach library',
    ];
  }

  @override
  void onReady() {
    super.onReady();
    _run();
  }

  Future<void> _run() async {
    // The request runs while the steps tick; its error is kept (not thrown)
    // so it is handled once, after the animation.
    final Future<Object> build = Get.find<AiSessionRepository>().buildSession(request).then<Object>((s) => s).catchError((Object e) => e);
    try {
      for (var i = 0; i < steps.length; i++) {
        await Future<void>.delayed(_step);
        if (!_alive) return;
        done.value = i + 1;
      }
      final Object result = await build;
      if (!_alive) return;
      if (result is AiSession) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (_alive) Get.offNamed<void>(AppRoutes.aiResult, arguments: result);
        return;
      }
      if (result is AiSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      AppLogger.error('AI build failed', error: result);
      AppToast.error(result is ApiException ? result.message : 'Could not build your session. Please try again.');
      Get.back<void>();
    } catch (e, st) {
      AppLogger.error('AI build failed', error: e, stackTrace: st);
      if (_alive) {
        AppToast.error('Could not build your session. Please try again.');
        Get.back<void>();
      }
    }
  }

  @override
  void onClose() {
    _alive = false;
    super.onClose();
  }
}
