import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/otp_controller.dart';

class OtpBinding extends Bindings {
  OtpBinding();

  @override
  void dependencies() {
    Get.lazyPut<OtpController>(OtpController.new);
  }
}
