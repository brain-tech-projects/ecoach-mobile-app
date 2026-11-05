import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';
import 'package:ecoach_pro/features/coach/presentation/widgets/invite_coach_dialog.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// Coach Invitation: the connected coach (with Disconnect).
class CoachInvitationController extends GetxController {
  CoachInvitationController(this._repository);

  final CoachRepository _repository;
  final Rxn<Coach> coach = Rxn<Coach>();
  final RxBool loading = true.obs;
  final RxBool disconnecting = false.obs;
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
      coach.value = await _repository.fetchConnectedCoach();
    } catch (error, stackTrace) {
      AppLogger.error('Coach load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your coach.';
    } finally {
      loading.value = false;
    }
  }

  /// "+" button: ask for the coach's email and send the invitation.
  void openInvite() => Get.dialog<void>(
    InviteCoachDialog(onSend: sendInvitation),
    barrierColor: const Color(0xB3000000),
  );

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
      AppToast.error(
        error is ApiException
            ? error.message
            : 'Could not send the invitation. Please try again.',
      );
      return false;
    }
  }

  Future<void> onDisconnect() async {
    final current = coach.value;
    if (current == null || disconnecting.value) return;

    final confirmed = await Get.dialog<bool>(
      const CompleteDialog(
        title: 'Disconnect Coach',
        message: 'Are you sure you want to disconnect from this coach? '
            'You will no longer receive skills set by them.',
      ),
      barrierColor: const Color(0xB3000000),
    );
    if (confirmed != true) return;

    disconnecting.value = true;
    try {
      await _repository.disconnect(current.id);
      coach.value = null;
      AppToast.success('Coach disconnected.');
    } catch (error, stackTrace) {
      AppLogger.error('Disconnect failed', error: error, stackTrace: stackTrace);
      AppToast.error(
        error is ApiException
            ? error.message
            : 'Could not disconnect. Please try again.',
      );
    } finally {
      disconnecting.value = false;
    }
  }
}
