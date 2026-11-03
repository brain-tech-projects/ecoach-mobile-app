import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/training/data/repositories/api_training_repository.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_controller.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_detail_controller.dart';

class TrainingBinding extends Bindings {
  TrainingBinding();

  @override
  void dependencies() {
    Get.lazyPut<TrainingRepository>(
      () => ApiTrainingRepository(Get.find<ApiService>()),
    );
    Get.put<TrainingController>(TrainingController(Get.find<TrainingRepository>()));
  }
}

class TrainingDetailBinding extends Bindings {
  TrainingDetailBinding();

  @override
  void dependencies() {
    Get.lazyPut<TrainingRepository>(
      () => ApiTrainingRepository(Get.find<ApiService>()),
    );
    Get.put<TrainingDetailController>(
      TrainingDetailController(Get.find<TrainingRepository>()),
    );
  }
}
