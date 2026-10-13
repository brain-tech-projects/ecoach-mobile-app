import 'package:flutter/material.dart';

/// Colours sampled from the eCoach Pro web app.
abstract final class AppColors {
  // Base
  static const Color background = Color(0xFF09232A);
  static const Color white = Color(0xFFFFFFFF);

  // Brand accent (links, pill text, active dot)
  static const Color accent = Color(0xFF69F675);

  // Accent at 18 % opacity -> pill fill (stays translucent over the glows)
  static const Color pillFill = Color(0x2E69F675);

  // Page-indicator dots
  static const Color dotActive = accent;
  static const Color dotInactive = Color(0xFF17532D);

  // Ambient background glows
  static const Color glowTopLeft = Color(0xFF164938);
  static const Color glowTopRight = Color(0xFF15404D);
  static const Color glowRightTeal = Color(0xFF1D4A48);
  static const Color glowRightGreen = Color(0xFF1F4B3E);
  static const Color glowBottomLeft = Color(0xFF134235);
}