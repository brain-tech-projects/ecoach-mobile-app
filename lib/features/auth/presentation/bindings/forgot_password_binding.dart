import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  ForgotPasswordBinding();

  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(ForgotPasswordController.new);
  }
}
