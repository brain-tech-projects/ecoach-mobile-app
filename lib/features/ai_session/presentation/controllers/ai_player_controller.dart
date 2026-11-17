import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_result_controller.dart';

/// Drill-by-drill player. Route arguments: [AiPlayerArgs].
class AiPlayerController extends GetxController {
  final AiPlayerArgs args = Get.arguments as AiPlayerArgs;
  final ScrollController scroll = ScrollController();
  late final RxInt index = args.index.obs;

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

  void next() {
    if (!isLast) {
      _go(index.value + 1);
      return;
    }
    AppToast.success('Session complete! +${session.totalPoints} points');
    Get.back<void>();
  }

  void exit() => Get.back<void>();

  @override
  void onClose() {
    scroll.dispose();
    super.onClose();
  }
}
