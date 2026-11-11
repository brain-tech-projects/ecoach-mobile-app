
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';

/// Animated glowing programme ring.
class ProgrammeRing extends StatefulWidget {
  const ProgrammeRing({
    super.key,
    required this.size,
  });

  final double size;

  @override
  State<ProgrammeRing> createState() => _ProgrammeRingState();
}

class _ProgrammeRingState extends State<ProgrammeRing>
    with SingleTickerProviderStateMixin {

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated ring image
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, child) {
                  final rotation = _c.value * 2 * math.pi;

                  // Subtle breathing / pulse effect
                  final scale = 1.0 +
                      0.015 *
                          math.sin(_c.value * 2 * math.pi);

                  return Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  AppAssets.programmeRing,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

            // Fixed center logo
            Image.asset(
              AppAssets.logo,
              height: size * 0.36,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ],
        ),
      ),
    );
  }
}
