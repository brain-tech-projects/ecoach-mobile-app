import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Borderless green text action ("Skip" / "Continue") with a 48 pt tap target.
/// The label cross-fades when it changes.
class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.scale = 1.0,
  });

  final String label;
  final VoidCallback onPressed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        overlayColor: AppColors.accent,
        minimumSize: const Size(96, 48),
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          label,
          key: ValueKey<String>(label),
          style: AppTextStyles.action.scaled(scale),
        ),
      ),
    );
  }
}