import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// "My Training" - the list of levels.
class TrainingController extends GetxController {
  TrainingController(this._repository);

  final TrainingRepository _repository;

  final RxList<TrainingLevel> levels = <TrainingLevel>[].obs;
  final Rxn<TrainingLevel> currentLevel = Rxn<TrainingLevel>();
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
      final res = await _repository.fetchLevels();
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success || res.data == null) {
        errorMessage.value = res.message;
        return;
      }
      levels.assignAll(res.data!.levels);
      currentLevel.value = res.data!.current;
    } catch (error, stackTrace) {
      AppLogger.error('Training load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your training.';
    } finally {
      isLoading.value = false;
    }
  }

  void openLevel(TrainingLevel level) {
    if (level.locked) {
      AppToast.info('Complete the previous level to unlock this one.');
      return;
    }
    Get.toNamed<void>(AppRoutes.trainingDetail, arguments: level);
  }
}
