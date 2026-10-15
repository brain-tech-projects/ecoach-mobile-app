import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Green progress bar with a "1 / 8" counter. Animates when the total changes.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.step,
    required this.total,
    this.scale = 1.0,
  });

  final int step;
  final int total;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fraction = total <= 0 ? 0.0 : (step / total).clamp(0.0, 1.0);

    return Semantics(
      label: 'Step $step of $total',
      excludeSemantics: true,
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4 * scale),
              child: SizedBox(
                height: 8 * scale,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const ColoredBox(color: AppColors.progressTrack),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction.toDouble(),
                      child: const ColoredBox(color: AppColors.selectGreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Text(
            '$step / $total',
            style: AppTextStyles.stepCounter.scaled(scale),
          ),
        ],
      ),
    );
  }
}
