import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Translucent green capsule that hugs its label (e.g. "Take on fun
/// challenges"). Wraps gracefully if the label is longer than the screen.
class AppPill extends StatelessWidget {
  const AppPill({super.key, required this.label, this.scale = 1.0});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.pillFill,
        shape: StadiumBorder(),
      ),
      child: Padding(
        // 12 pt text x 1.5 line height (18) + 2 x 9 = 36 pt tall, like the web.
        padding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 9 * scale,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.pill.scaled(scale),
        ),
      ),
    );
  }
}