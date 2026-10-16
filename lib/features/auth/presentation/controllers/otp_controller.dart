import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';

class OtpController extends GetxController {
  static const int codeLength = 6;

  final TextEditingController codeController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final RxnString error = RxnString();

  /// Parent / guardian email passed from the sign-up flow.
  final String email = Get.arguments is String ? Get.arguments as String : '';

  void onChanged(String _) {
    if (error.value != null) error.value = null;
  }

  void verify() {
    if (codeController.text.length < codeLength) {
      error.value = 'Please enter the $codeLength-digit code.';
      return;
    }
    // TODO(api): verify the code, then continue.
    Get.offAllNamed<void>(AppRoutes.dashboard);
  }

  void resend() {
    // TODO(api): request a new code.
  }

  @override
  void onClose() {
    codeController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
