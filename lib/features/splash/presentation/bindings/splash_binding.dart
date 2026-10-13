import 'package:get/get.dart';

import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/features/splash/presentation/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  SplashBinding();

  @override
  void dependencies() {
    // `put` (not lazyPut) so onReady() always fires even though the page
    // itself never reads the controller.
    Get.put<SplashController>(SplashController(Get.find<LocalStorage>()));
  }
}