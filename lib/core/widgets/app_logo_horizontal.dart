import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/constants/app_strings.dart';

/// Horizontal "crest + E-COACH PRO" logo used on the auth screens.
class AppLogoHorizontal extends StatelessWidget {
  const AppLogoHorizontal({super.key, this.scale = 1.0});

  static const double designWidth = 197;
  static const double designHeight = 87.3;

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoHorizontal,
      width: designWidth * scale,
      height: designHeight * scale,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: AppStrings.appName,
    );
  }
}
