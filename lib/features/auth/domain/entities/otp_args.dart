import 'package:flutter/foundation.dart';

/// Why the OTP screen is open.
enum OtpPurpose {
  /// Parent / guardian email check after sign-up (players aged 12 or under).
  signUp,

  /// "Forgot password" email check.
  resetPassword,
}

/// Arguments for `AppRoutes.otp`.
@immutable
class OtpArgs {
  const OtpArgs({
    required this.email,
    required this.purpose,
    this.userId,
    this.password,
  });

  final String email;
  final OtpPurpose purpose;

  /// Sign-up only: id returned by `register`.
  final int? userId;

  /// Sign-up only: used to sign the user in right after verification.
  final String? password;
}
