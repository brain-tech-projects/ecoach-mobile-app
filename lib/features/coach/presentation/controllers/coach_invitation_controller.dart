import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';
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
      AppToast.error('Could not disconnect. Please try again.');
    } finally {
      disconnecting.value = false;
    }
  }
}
