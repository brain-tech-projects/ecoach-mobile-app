import 'package:flutter/material.dart';

/// Colours sampled from the eCoach Pro web app.
abstract final class AppColors {
  // Base
  static const Color background = Color(0xFF09232A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Brand accent (links, pill text, active dot, primary buttons)
  static const Color accent = Color(0xFF69F675);
  static const Color pillFill = Color(0x2E69F675); // accent @ 18 %

  // Onboarding dots
  static const Color dotActive = accent;
  static const Color dotInactive = Color(0xFF17532D);

  // Ambient background glows
  static const Color glowTopLeft = Color(0xFF164938);
  static const Color glowTopRight = Color(0xFF15404D);
  static const Color glowRightTeal = Color(0xFF1D4A48);
  static const Color glowRightGreen = Color(0xFF1F4B3E);
  static const Color glowBottomLeft = Color(0xFF134235);

  // Auth: role selection
  static const Color selectGreen = Color(0xFF4AD82B);
  static const Color selectedFill = Color(0x214AD82B);
  static const Color unselectedBorder = Color(0xFF6C757D);
  static const Color checkIdle = Color(0xFF54676A);
  static const Color checkMark = Color(0xFF0E2C33);
  static const Color progressTrack = Color(0xFF253A40);

  // Auth: inputs & buttons
  static const Color fieldFill = Color(0xFF2B4046);
  static const Color fieldBorder = Color(0xFF65696A);
  static const Color hint = Color(0xFF7B8090);
  static const Color buttonGlow = Color(0x3D5B7FC8);

  // Dashboard
  static const Color headerBg = Color(0xFF223940);
  static const Color avatarBg = Color(0xFFF0F1F4);
  static const Color avatarFg = Color(0xFF5D6163);
  static const Color menuCircle = Color(0xFF7D898D);
  static const Color card = Color(0xFF2B4046);
  static const Color cardBorder = Color(0xFF6F7272);
  static const Color cardCircle = Color(0xFF3F5256);
  static const Color navBg = Color(0xFF233B42);
  static const Color navBorder = Color(0xFF6E7172);
  static const Color descGrey = Color(0xFFB9B9B9);

  // Sign-up flow
  static const Color error = Color(0xFFE5283C);
  static const Color textMuted = Color(0xFFC1C1C1);
  static const Color countryFill = Color(0xFF233A40);
  static const Color countryBorder = Color(0xFF3D5C61);
  static const Color checkboxBorder = Color(0xFF586F6F);

  // Side menu / settings / contact
  static const Color menuIcon = Color(0xFF60E46F);
  static const Color avatarGradTop = Color(0xFF0F3A2F);
  static const Color avatarGradBottom = Color(0xFF4CCB59);
  static const Color termsCardFill = Color(0xFF1A3137);
  static const Color termsCardBorder = Color(0xFF42555A);
  static const Color termsContentFill = Color(0xFF162E35);
  static const Color termsText = Color(0xFFD6D9DA);

  // Training / skills / video
  static const Color ringTrack = Color(0xFF8A9598);
  static const Color skillPillFill = Color(0xFF243B42);
  static const Color skillPillBorder = Color(0xFF696D6E);
  static const Color popupBg = Color(0xFF0B3743);
  static const Color popupDivider = Color(0xFF476A73);
  static const Color dialogBg = Color(0xFF0B3542);
  static const Color toastText = Color(0xFF212529);
  static const Color menuPanelText = Color(0xFF202124);
  static const Color checkBlue = Color(0xFF4285F4);
  static const Color playOverlay = Color(0x4769F675);
}
