import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

/// Translucent green circle with a play triangle (video "not started" mark).
class PlayOverlay extends StatelessWidget {
  const PlayOverlay({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.playOverlay,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.play_arrow_rounded, size: size * 0.62, color: AppColors.accent),
    );
  }
}
