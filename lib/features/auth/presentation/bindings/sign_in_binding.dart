import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  SignInBinding();

  @override
  void dependencies() {
    Get.lazyPut<SignInController>(SignInController.new);
  }
}
