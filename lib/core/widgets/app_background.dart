import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

/// The dark-navy backdrop with soft green / teal ambient glows used on every
/// eCoach Pro screen. Painted once (cached by [RepaintBoundary]) so it adds no
/// per-frame cost, and scales to any screen size.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: CustomPaint(
            painter: _GlowPainter(),
            size: Size.infinite,
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _Glow {
  const _Glow({
    required this.centerX,
    required this.centerY,
    required this.radiusX,
    required this.radiusY,
    required this.color,
  });

  /// Centre as a fraction of the canvas width / height.
  final double centerX;
  final double centerY;

  /// Radii as a fraction of the canvas WIDTH (keeps glows the same physical
  /// size on tall and short screens).
  final double radiusX;
  final double radiusY;

  final Color color;
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter();

  static const List<double> _stops = <double>[0.0, 0.4, 0.8, 1.0];
  static const List<double> _alphas = <double>[1.0, 0.55, 0.12, 0.0];

  // Tuned against the web screenshots (mean error ~1/255 per channel).
  static const List<_Glow> _glows = <_Glow>[
    _Glow(
      centerX: 0,
      centerY: 0,
      radiusX: 0.58,
      radiusY: 0.58,
      color: AppColors.glowTopLeft,
    ),
    _Glow(
      centerX: 1,
      centerY: 0,
      radiusX: 0.51,
      radiusY: 0.45,
      color: AppColors.glowTopRight,
    ),
    _Glow(
      centerX: 1,
      centerY: 0.626,
      radiusX: 0.30,
      radiusY: 0.42,
      color: AppColors.glowRightTeal,
    ),
    _Glow(
      centerX: 1,
      centerY: 0.745,
      radiusX: 0.30,
      radiusY: 0.45,
      color: AppColors.glowRightGreen,
    ),
    _Glow(
      centerX: 0,
      centerY: 1,
      radiusX: 0.50,
      radiusY: 0.50,
      color: AppColors.glowBottomLeft,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = AppColors.background);

    for (final glow in _glows) {
      final radiusX = glow.radiusX * size.width;
      final radiusY = glow.radiusY * size.width;
      if (radiusX <= 0 || radiusY <= 0) continue;

      canvas.save();
      canvas.clipRect(bounds);
      canvas.translate(glow.centerX * size.width, glow.centerY * size.height);
      // Turn the circular gradient into an ellipse.
      canvas.scale(1, radiusY / radiusX);

      final shader = RadialGradient(
        colors: <Color>[
          for (final alpha in _alphas) glow.color.withValues(alpha: alpha),
        ],
        stops: _stops,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radiusX));

      canvas.drawPaint(Paint()..shader = shader);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) => false;
}