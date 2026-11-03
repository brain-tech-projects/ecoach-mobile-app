import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

class SignInController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<void> signIn() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    final emailError = Validators.requiredField(email, 'Email');
    if (emailError != null) {
      AppToast.error(emailError);
      return;
    }
    if (!Validators.isEmail(email)) {
      AppToast.error('The Email must be a valid email address.');
      return;
    }
    final passwordError = Validators.requiredField(password, 'Password');
    if (passwordError != null) {
      AppToast.error(passwordError);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final res = await _api.login(email: email, password: password);
      if (!res.success) {
        AppToast.error(res.message);
        return;
      }
      Get.offAllNamed<void>(AppRoutes.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void openSignUp() => Get.toNamed<void>(AppRoutes.signUp);

  void openForgotPassword() => Get.toNamed<void>(
    AppRoutes.forgotPassword,
    arguments: emailController.text.trim(),
  );

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
