import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/login_page.dart';
import 'package:ecoach_pro/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:ecoach_pro/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:ecoach_pro/features/splash/presentation/bindings/splash_binding.dart';
import 'package:ecoach_pro/features/splash/presentation/pages/splash_page.dart';

abstract final class AppPages {
  static const String initial = AppRoutes.splash;

  static const Duration _fade = Duration(milliseconds: 500);

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
    GetPage<void>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
    GetPage<void>(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
  ];
}