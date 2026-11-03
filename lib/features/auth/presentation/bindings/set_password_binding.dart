import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/set_password_controller.dart';

class SetPasswordBinding extends Bindings {
  SetPasswordBinding();

  @override
  void dependencies() {
    Get.lazyPut<SetPasswordController>(SetPasswordController.new);
  }
}
