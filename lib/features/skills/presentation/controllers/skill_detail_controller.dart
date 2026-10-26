import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// One drill video + "Video Complete" (points are earned once).
class SkillDetailController extends GetxController {
  final Drill drill = Get.arguments as Drill;

  final RxBool completed = false.obs;

  Future<void> onVideoComplete() async {
    if (completed.value) return;
    final confirmed = await Get.dialog<bool>(
      const CompleteDialog(),
      barrierColor: const Color(0xB3000000),
    );
    if (confirmed != true) return;

    // TODO(api): send the completion to the backend (points).
    completed.value = true;
    AppToast.success('Skill video marked as completed');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    AppToast.reward(
      title: 'Skill Video Completed',
      message: "You completed '${drill.title}' and earned ${drill.points} points!",
    );
  }
}
