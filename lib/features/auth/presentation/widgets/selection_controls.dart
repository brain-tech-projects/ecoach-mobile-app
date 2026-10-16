import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

/// Round check badge (single choice). Dark tick, green when selected.
class CircleCheck extends StatelessWidget {
  const CircleCheck({super.key, required this.selected, required this.scale});

  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26 * scale,
      height: 26 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.selectGreen : AppColors.checkIdle,
      ),
      child: Icon(Icons.check, size: 16 * scale, color: AppColors.checkMark),
    );
  }
}

/// Rounded checkbox (multiple choice). White tick on green when selected.
class SquareCheck extends StatelessWidget {
  const SquareCheck({super.key, required this.selected, required this.scale});

  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 19.3 * scale,
      height: 19.3 * scale,
      decoration: BoxDecoration(
        color: selected ? AppColors.selectGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(5 * scale),
        border: selected
            ? null
            : Border.all(color: AppColors.checkboxBorder, width: 1.5),
      ),
      child: selected
          ? Icon(Icons.check, size: 15 * scale, color: AppColors.white)
          : null,
    );
  }
}
