import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// One coach-assigned training video. Open with `arguments: AssignedTraining`.
class CoachTrainingDetailController extends GetxController {
  CoachTrainingDetailController(this._repository);

  final CoachRepository _repository;
  final AssignedTraining training = Get.arguments as AssignedTraining;

  final RxBool completing = false.obs;
  bool _completed = false;

  Future<void> onVideoComplete() async {
    if (completing.value) return;
    if (_completed) {
      AppToast.info('Already marked as completed');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      const CompleteDialog(
        title: 'Complete Assigned Skill',
        message: 'Are you sure you want to mark this coach-assigned skill as '
            'completed? Your progress will be updated, and you can continue '
            'practising this skill anytime.',
      ),
      barrierColor: const Color(0xB3000000),
    );
    if (confirmed != true) return;

    completing.value = true;
    try {
      await _repository.completeTraining(training.id);
      _completed = true;
      AppToast.success('Training program marked as completed.');
    } catch (error, stackTrace) {
      AppLogger.error('Complete training failed',
          error: error, stackTrace: stackTrace);
      AppToast.error('Could not complete the training. Please try again.');
    } finally {
      completing.value = false;
    }
  }
}
