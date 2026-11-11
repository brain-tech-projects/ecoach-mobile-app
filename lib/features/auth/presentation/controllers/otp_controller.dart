import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/auth/domain/entities/otp_args.dart';

/// Shared by both OTP flows (see [OtpPurpose]).
class OtpController extends GetxController {
  static const int codeLength = 6;

  final ApiService _api = Get.find<ApiService>();

  final TextEditingController codeController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final RxnString error = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;

  late final OtpArgs args = Get.arguments is OtpArgs
      ? Get.arguments as OtpArgs
      : const OtpArgs(email: '', purpose: OtpPurpose.signUp);

  String get email => args.email;
  bool get isReset => args.purpose == OtpPurpose.resetPassword;

  void onChanged(String _) {
    if (error.value != null) error.value = null;
  }

  Future<void> verify() async {
    if (isLoading.value) return;
    if (codeController.text.length < codeLength) {
      error.value = 'Please enter the $codeLength-digit code.';
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    try {
      if (isReset) {
        await _verifyReset();
      } else {
        await _verifySignUp();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyReset() async {
    final res = await _api.verifyResetOtp(
      email: email,
      otp: codeController.text,
    );
    if (!res.success) {
      error.value = res.message;
      return;
    }
    Get.offNamed<void>(AppRoutes.setNewPassword, arguments: email);
  }

    Future<void> _verifySignUp() async {
    final userId = args.userId;
    if (userId == null) {
      error.value = 'Session expired. Please sign up again.';
      return;
    }
    final res = await _api.verifyOtp(
      userId: userId,
      parentGuardianEmail: email,
      otp: codeController.text,
    );
    if (!res.success) {
      error.value = res.message;
      return;
    }

    // Verified -> players/parents see the programme screens first;
    // "Unlock" there signs them in.
    final programme = args.programme;
    if (programme != null) {
      AppToast.success('Email verified.');
      Get.offAllNamed<void>(AppRoutes.programme, arguments: programme);
      return;
    }

    // Otherwise sign in with the credentials from the sign-up form.
    final password = args.password;
    if (password != null) {
      final login = await _api.login(email: email, password: password);
      if (login.success) {
        Get.offAllNamed<void>(AppRoutes.dashboard);
        return;
      }
    }
    AppToast.success('Email verified. Please sign in.');
    Get.offAllNamed<void>(AppRoutes.signIn);
  }

  Future<void> resend() async {
    if (isResending.value || isLoading.value) return;
    isResending.value = true;
    try {
      final res = isReset
          ? await _api.forgotPassword(email: email)
          : await _resendSignUp();
      if (res == null) return;
      codeController.clear();
      error.value = null;
      if (res.success) {
        AppToast.success(res.message);
      } else {
        AppToast.error(res.message);
      }
    } finally {
      isResending.value = false;
    }
  }

  Future<ApiResponse<void>?> _resendSignUp() async {
    final userId = args.userId;
    if (userId == null) {
      AppToast.error('Session expired. Please sign up again.');
      return null;
    }
    return _api.resendOtp(userId: userId, parentGuardianEmail: email);
  }

  /// Reset flow: go back and type a different email.
  void changeEmail() => Get.back<void>();

  @override
  void onClose() {
    codeController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
