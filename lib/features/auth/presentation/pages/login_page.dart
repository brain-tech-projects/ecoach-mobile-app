import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_background.dart';
import 'package:ecoach_pro/core/widgets/app_logo.dart';

/// PLACEHOLDER - replace with the real login screen in the next step.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppLogo(scale: r.scale),
              SizedBox(height: r.s(32)),
              Text(
                'Login - coming next',
                style: AppTextStyles.onboardingBody.scaled(r.scale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}