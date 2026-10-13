import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/constants/app_strings.dart';

/// The eCoach Pro crest + "TRAIN LIKE A PRO" tagline.
///
/// Wrapped in a [Hero] by default so the logo glides from the centre of the
/// splash screen to the top of the onboarding screen.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.scale = 1.0,
    this.heroTag = defaultHeroTag,
  });

  static const String defaultHeroTag = 'app-logo';

  /// Logical size at the 393 pt design width (matches the web app).
  static const double designWidth = 135;
  static const double designHeight = 161;

  final double scale;

  /// Pass `null` to disable the hero transition.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      AppAssets.logo,
      width: designWidth * scale,
      height: designHeight * scale,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      semanticLabel: AppStrings.appName,
    );

    final tag = heroTag;
    if (tag == null) return logo;
    return Hero(tag: tag, child: logo);
  }
}