import 'package:get/get.dart';

import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/features/onboarding/presentation/controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  OnboardingBinding();

  @override
  void dependencies() {
    Get.put<OnboardingController>(
      OnboardingController(Get.find<LocalStorage>()),
    );
  }
}