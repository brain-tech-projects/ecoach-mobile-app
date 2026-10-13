import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
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

    // TODO(auth): if a valid session token exists, go to the home route.
    final next = _storage.isOnboardingCompleted
        ? AppRoutes.login
        : AppRoutes.onboarding;
    Get.offNamed<void>(next);
  }
}