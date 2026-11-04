import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Colours used only by the Fun tab (measured from the design).
abstract final class FunColors {
  static const Color hubTile = Color(0xFF264D40);
  static const Color optionSelected = Color(0xFF3E7054);
  static const Color previousButton = Color(0xFF4BB35D);
  static const Color disabledOutline = Color(0xFFB3BABC);
  static const Color scoreText = Color(0xFFCECECE);
  static const Color heartRed = Color(0xFFF53B3B);
  static const Color heartBackdrop = Color(0xCC000000);
}

abstract final class FunTextStyles {
  static const String _f = AppTextStyles.fontFamily;

  static const TextStyle hubLabel = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, color: Colors.white);
  static const TextStyle challengeTitle = TextStyle(fontFamily: _f, fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: Colors.white);
  static const TextStyle counter = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.background);
  static const TextStyle question = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: Colors.white);
  static const TextStyle option = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w400, height: 1.4, color: Colors.white);
  static const TextStyle letter = TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w500, height: 1.2, color: Colors.white);
  static const TextStyle button = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w500, height: 1.2);
  static const TextStyle introTitle = TextStyle(fontFamily: _f, fontSize: 21.5, fontWeight: FontWeight.w600, height: 1.5, color: Colors.white);
  static const TextStyle introSub = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textMuted);
  static const TextStyle resultTitle = TextStyle(fontFamily: _f, fontSize: 25, fontWeight: FontWeight.w500, height: 1.5, color: Colors.white);
  static const TextStyle resultScore = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: FunColors.scoreText);
  static const TextStyle resultLink = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.accent);
  static const TextStyle resultAnother = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: Colors.white);
}
