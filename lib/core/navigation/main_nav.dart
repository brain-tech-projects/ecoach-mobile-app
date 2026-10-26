import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/session_service.dart';

/// Shared behaviour of the bottom tab bar and the top-right menu button.
abstract final class MainNav {
  /// Bottom tabs: 0 Training, 1 Skills, 2 Home, 3 Fun, 4 Tracker.
  static const int trainingIndex = 0;
  static const int skillsIndex = 1;
  static const int homeIndex = 2;

  static const Set<String> _tabRoutes = <String>{
    AppRoutes.training,
    AppRoutes.skills,
  };

  static void onTabSelected(int index) {
    if (index == homeIndex) {
      if (Get.currentRoute != AppRoutes.dashboard) {
        Get.offAllNamed<void>(AppRoutes.dashboard);
      }
      return;
    }

    // Training and Skills are open to everyone (demo content for now).
    if (index == trainingIndex) return _openTab(AppRoutes.training);
    if (index == skillsIndex) return _openTab(AppRoutes.skills);

    // Fun / Tracker: signed-out users are sent to login / sign-up.
    if (!Get.find<SessionService>().isLoggedIn.value) {
      Get.toNamed<void>(AppRoutes.signIn);
      return;
    }

    // TODO(tabs): open Fun / Tracker for signed-in users.
  }

  /// Switching between tab pages replaces the current tab instead of piling
  /// pages up; from anywhere else the tab opens on top (back returns).
  static void _openTab(String route) {
    final current = Get.currentRoute;
    if (current == route) return;
    if (_tabRoutes.contains(current)) {
      Get.offNamed<void>(route);
    } else {
      Get.toNamed<void>(route);
    }
  }

  static void openMenu() => Get.toNamed<void>(AppRoutes.menu);
}
