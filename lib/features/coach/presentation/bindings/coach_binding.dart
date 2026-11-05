import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/coach/data/repositories/api_coach_repository.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_invitation_controller.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_training_controller.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_training_detail_controller.dart';

/// One shared repository for the coach pages. Swap in the API version here.
void ensureCoachRepository() {
  if (!Get.isRegistered<CoachRepository>()) {
    Get.put<CoachRepository>(
      ApiCoachRepository(Get.find<ApiService>()),
      permanent: true,
    );
  }
}

class CoachInvitationBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachRepository();
    Get.lazyPut<CoachInvitationController>(
      () => CoachInvitationController(Get.find<CoachRepository>()),
    );
  }
}

class CoachTrainingBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachRepository();
    Get.lazyPut<CoachTrainingController>(
      () => CoachTrainingController(Get.find<CoachRepository>()),
    );
  }
}

class CoachTrainingDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachRepository();
    Get.lazyPut<CoachTrainingDetailController>(
      () => CoachTrainingDetailController(Get.find<CoachRepository>()),
    );
  }
}
