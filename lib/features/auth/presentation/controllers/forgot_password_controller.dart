import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/auth/domain/entities/otp_args.dart';

class ForgotPasswordController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  /// Pre-filled with whatever was typed on the sign-in screen.
  late final TextEditingController emailController = TextEditingController(
    text: Get.arguments is String ? Get.arguments as String : '',
  );

  final RxnString emailError = RxnString();
  final RxBool isLoading = false.obs;

  void onEmailChanged(String _) {
    if (emailError.value != null) emailError.value = null;
  }

  Future<void> send() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final required = Validators.requiredField(email, 'Email');
    if (required != null) {
      emailError.value = required;
      return;
    }
    if (!Validators.isEmail(email)) {
      emailError.value = 'The Email must be a valid email address.';
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final res = await _api.forgotPassword(email: email);
      if (!res.success) {
        emailError.value = res.message;
        return;
      }
      AppToast.success(res.message);
      Get.toNamed<void>(
        AppRoutes.otp,
        arguments: OtpArgs(email: email, purpose: OtpPurpose.resetPassword),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openSignUp() => Get.offNamed<void>(AppRoutes.signUp);

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
