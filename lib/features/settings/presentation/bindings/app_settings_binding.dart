import 'package:get/get.dart';

import 'package:ecoach_pro/features/settings/presentation/controllers/app_settings_controller.dart';

class AppSettingsBinding extends Bindings {
  AppSettingsBinding();

  @override
  void dependencies() {
    Get.lazyPut<AppSettingsController>(AppSettingsController.new);
  }
}
