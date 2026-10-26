import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// "My Training" - the list of levels.
class TrainingController extends GetxController {
  TrainingController(this._repository);

  final TrainingRepository _repository;

  final RxList<TrainingLevel> levels = <TrainingLevel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      levels.assignAll(await _repository.fetchLevels());
    } catch (error, stackTrace) {
      AppLogger.error('Training load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your training.';
    } finally {
      isLoading.value = false;
    }
  }

  void openLevel(TrainingLevel level) =>
      Get.toNamed<void>(AppRoutes.trainingDetail, arguments: level);
}
