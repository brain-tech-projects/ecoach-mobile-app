import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  SignUpBinding();

  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(SignUpController.new);
  }
}
