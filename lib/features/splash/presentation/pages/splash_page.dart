import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_background.dart';
import 'package:ecoach_pro/core/widgets/app_logo.dart';

/// Same background as the onboarding screens with the logo dead-centre.
/// Navigation is driven by `SplashController`.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
            ),
            child: AppLogo(scale: r.scale),
          ),
        ),
      ),
    );
  }
}