import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';

/// 90 x 81.7 pt thumbnail in the level's video row (padlock when locked).
class TrainingVideoThumb extends StatelessWidget {
  const TrainingVideoThumb({
    super.key,
    required this.locked,
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final bool locked;
  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: locked ? '$label, locked' : label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10 * s),
            child: Image.asset(
              locked ? AppAssets.thumbLocked : AppAssets.thumbActive,
              width: 90 * s,
              height: 81.7 * s,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
