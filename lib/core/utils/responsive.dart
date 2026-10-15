import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Proportional scaling based on the web design (iPhone 16: 393 x 852).
///
/// Every design value (font size, padding, logo size...) is multiplied by
/// [scale], so the layout keeps the exact proportions of the design on small
/// phones, large phones and tablets.
class Responsive {
  const Responsive._({
    required this.scale,
    required this.size,
    required this.padding,
  });

  static const double designWidth = 393;
  static const double designHeight = 852;
  static const double minScale = 0.8;
  static const double maxScale = 1.3;

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final raw = math.min(
      size.width / designWidth,
      size.height / designHeight,
    );
    return Responsive._(
      scale: raw.clamp(minScale, maxScale).toDouble(),
      size: size,
      padding: padding,
    );
  }

  final double scale;
  final Size size;
  final EdgeInsets padding;

  /// Scale a design value.
  double s(double value) => value * scale;

  double get safeTop => padding.top;
  double get safeBottom => padding.bottom;

  /// Content never grows wider than the design width (keeps tablets tidy).
  double get contentMaxWidth => designWidth * scale;

  /// Empty space on each side when the screen is wider than the design.
  double get gutter => math.max(0.0, (size.width - contentMaxWidth) / 2);

  bool get isTablet => size.shortestSide >= 600;
}

extension ResponsiveContext on BuildContext {
  Responsive get r => Responsive.of(this);
}
