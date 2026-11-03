import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/drill_actions.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/notes_dialog.dart';

/// One drill: video, description, "Video Complete" (points are earned once).
class SkillDetailController extends GetxController {
  SkillDetailController(this._repository);

  final SkillsRepository _repository;

  /// Starts as the list item (title, thumbnail) and is replaced by the full
  /// details once they load.
  late final Rx<Drill> drill = Rx<Drill>(Get.arguments as Drill);

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString errorMessage = RxnString();

  bool get completed => drill.value.completed;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repository.fetchDrill(drill.value.id);
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success || res.data == null) {
        errorMessage.value = res.message;
        return;
      }
      drill.value = drill.value.withDetails(res.data!);
    } catch (error, stackTrace) {
      AppLogger.error('Drill load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load this video.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onVideoComplete() async {
    if (completed || isSubmitting.value) return;
    final confirmed = await Get.dialog<bool>(
      const CompleteDialog(),
      barrierColor: const Color(0xB3000000),
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      final res = await _repository.markCompleted(drill.value.id);
      if (res.isSubscriptionRequired) {
        Get.toNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        AppToast.error(res.message);
        return;
      }
      drill.value = drill.value.copyWith(completed: true);
      AppToast.success(res.message);
      final points = drill.value.points;
      if (points > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        AppToast.reward(
          title: 'Skill Video Completed',
          message:
              "You completed '${drill.value.title}' and earned $points points!",
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleSession() async {
    final updated = await DrillActions.toggleSession(_repository, drill.value);
    if (updated != null) drill.value = updated;
  }

  Future<void> toggleMySkills() async {
    final updated = await DrillActions.toggleMySkills(_repository, drill.value);
    if (updated != null) drill.value = updated;
  }

  void addNote() => showNotesDialog(drill.value);
}
