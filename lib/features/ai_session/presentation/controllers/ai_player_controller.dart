import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_result_controller.dart';

/// Drill-by-drill player. Route arguments: [AiPlayerArgs].
class AiPlayerController extends GetxController {
  final AiPlayerArgs args = Get.arguments as AiPlayerArgs;
  final ScrollController scroll = ScrollController();
  late final RxInt index = args.index.obs;

  /// Request running (Next / Finish buttons show a spinner).
  final RxBool busy = false.obs;
  final Set<String> _done = <String>{};
  int _earned = 0;

  AiSessionRepository get _repo => Get.find<AiSessionRepository>();

  AiSession get session => args.session;
  AiDrill get drill => session.drills[index.value];
  int get total => session.drills.length;
  bool get isFirst => index.value == 0;
  bool get isLast => index.value == total - 1;
  double get progress => (index.value + 1) / total;

  void _go(int i) {
    index.value = i;
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void jumpTo(int i) {
    if (i != index.value) _go(i);
  }

  void previous() {
    if (!isFirst) _go(index.value - 1);
  }

  /// Marks the current drill done on the server (once), then moves on;
  /// on the last drill the whole session is completed.
  Future<void> next() async {
    if (busy.value) return;
    busy.value = true;
    try {
      await _completeCurrent();
      if (!isLast) {
        _go(index.value + 1);
        return;
      }
      _earned += await _repo.completeSession(session.id);
      AppToast.success(_earned > 0 ? 'Session complete! +$_earned points' : 'Session complete!');
      Get.back<void>();
    } catch (e, st) {
      AppLogger.error('AI drill complete failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not save your progress. Please try again.');
    } finally {
      busy.value = false;
    }
  }

  Future<void> _completeCurrent() async {
    final d = drill;
    final key = '${d.type}:${d.id}';
    if (d.completed || d.locked || _done.contains(key)) return;
    _earned += await _repo.completeDrill(session.id, d);
    _done.add(key);
  }

  void exit() => Get.back<void>();

  @override
  void onClose() {
    scroll.dispose();
    super.onClose();
  }
}
