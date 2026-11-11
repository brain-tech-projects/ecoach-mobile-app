import 'dart:ui';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/presentation/widgets/invite_coach_dialog.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';

/// Coaches Training: list of skills the coach has set.
class CoachTrainingController extends GetxController {
  CoachTrainingController(this._repository);

  final CoachRepository _repository;
  final RxList<AssignedTraining> trainings = <AssignedTraining>[].obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      trainings.assignAll(await _repository.fetchAssignedTrainings());
    } catch (error, stackTrace) {
      AppLogger.error('Assigned trainings load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your training.';
    } finally {
      loading.value = false;
    }
  }

  void open(AssignedTraining training) => Get.toNamed<void>(AppRoutes.coachTrainingDetail, arguments: training);

  /// "+" button: ask for the coach's email and send the invitation.
  void openInvite() => Get.dialog<void>(InviteCoachDialog(onSend: sendInvitation), barrierColor: const Color(0xB3000000));

  /// true = sent (the dialog closes).
  Future<bool> sendInvitation(String email) async {
    final value = email.trim();
    if (!Validators.isEmail(value)) {
      AppToast.error('Please enter a valid email address.');
      return false;
    }
    try {
      final message = await _repository.inviteCoach(value);
      AppToast.success(message);
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Invite failed', error: error, stackTrace: stackTrace);
      AppToast.error(error is ApiException ? error.message : 'Could not send the invitation. Please try again.');
      return false;
    }
  }
}
