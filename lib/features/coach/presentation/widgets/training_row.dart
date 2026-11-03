import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// One coach-assigned skill: rounded dark bar with the name.
class TrainingRow extends StatelessWidget {
  const TrainingRow({
    super.key,
    required this.title,
    required this.scale,
    required this.onTap,
  });

  final String title;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(18 * s);

    return Semantics(
      button: true,
      label: title,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 36.3 * s),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 11.3 * s, vertical: 6 * s),
              child: Text(
                title,
                style: AppTextStyles.menuItem.scaled(s),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
