import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

class SetPasswordController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  /// Email verified in the previous step.
  final String email = Get.arguments is String ? Get.arguments as String : '';

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool isLoading = false.obs;

  final RxnString passwordError = RxnString();
  final RxnString confirmError = RxnString();

  void togglePassword() => obscurePassword.value = !obscurePassword.value;
  void toggleConfirm() => obscureConfirm.value = !obscureConfirm.value;

  void onPasswordChanged(String _) => passwordError.value = null;
  void onConfirmChanged(String _) => confirmError.value = null;

  bool _validate() {
    passwordError.value = Validators.requiredField(
      passwordController.text,
      'Password',
    );
    confirmError.value =
        Validators.requiredField(confirmController.text, 'Confirm Password') ??
        (confirmController.text == passwordController.text
            ? null
            : 'The password confirmation does not match.');
    return passwordError.value == null && confirmError.value == null;
  }

  Future<void> submit() async {
    if (isLoading.value || !_validate()) return;
    if (email.isEmpty) {
      AppToast.error('Session expired. Please start again.');
      Get.offAllNamed<void>(AppRoutes.signIn);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      final res = await _api.resetPassword(
        email: email,
        password: passwordController.text,
        passwordConfirmation: confirmController.text,
      );
      if (!res.success) {
        final field = res.fieldError('password');
        if (field != null) {
          passwordError.value = field;
        } else {
          AppToast.error(res.message);
        }
        return;
      }
      AppToast.success(res.message);
      Get.offAllNamed<void>(AppRoutes.signIn);
    } finally {
      isLoading.value = false;
    }
  }

  void openSignUp() => Get.offAllNamed<void>(AppRoutes.signUp);

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
