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
      AppLogger.error('Assigned trainings load failed',
          error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your training.';
    } finally {
      loading.value = false;
    }
  }

  void open(AssignedTraining training) =>
      Get.toNamed<void>(AppRoutes.coachTrainingDetail, arguments: training);
}
