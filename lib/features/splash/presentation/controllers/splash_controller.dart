import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/constants/app_config.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/utils/logger.dart';

class SplashController extends GetxController {
  SplashController(this._storage);

  final LocalStorage _storage;

  /// Minimum time the splash stays visible (logo animation + brand moment).
  static const Duration minDuration = Duration(milliseconds: 2200);

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Run any start-up work here in parallel with the minimum delay,
      // e.g. refresh remote config, validate stored session token, etc.
      await Future<void>.delayed(minDuration);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Splash bootstrap failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // First launch  -> onboarding (shown once, flag saved when it finishes).
    // Every launch after that -> straight to the dashboard.
    // `AppConfig.alwaysShowOnboarding` is a QA-only override (dart-define).
    final showOnboarding =
        AppConfig.alwaysShowOnboarding || !_storage.isOnboardingCompleted;

    Get.offNamed<void>(
      showOnboarding ? AppRoutes.onboarding : AppRoutes.dashboard,
    );
  }
}
