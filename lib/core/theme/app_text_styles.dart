import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

/// Base styles at the 393 pt design width. Always apply
/// `.scaled(context.r.scale)` so they track the screen size.
abstract final class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.white,
  );

  static const TextStyle onboardingBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.white,
  );

  static const TextStyle pill = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.accent,
  );

  static const TextStyle action = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.accent,
  );
}

extension TextStyleScaling on TextStyle {
  TextStyle scaled(double factor) =>
      copyWith(fontSize: (fontSize ?? 14) * factor);
}