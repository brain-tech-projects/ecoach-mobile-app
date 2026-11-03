import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/session_service.dart';

/// Put on every page that needs an account. Signed-out users who try to open
/// it (tab, button, deep link...) land on the login page instead.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({super.priority = 1});

  @override
  RouteSettings? redirect(String? route) {
    final loggedIn =
        Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().isLoggedIn.value;
    return loggedIn ? null : const RouteSettings(name: AppRoutes.signIn);
  }
}
