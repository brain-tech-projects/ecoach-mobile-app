import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_pages.dart';
import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

/// Shared behaviour of the bottom tab bar, the menu button and every other
/// "open a page" button. Signed-out users only get the Home page: anything
/// else sends them to login first.
abstract final class MainNav {
  /// Bottom tabs: 0 Training, 1 Skills, 2 Home, 3 Fun, 4 Tracker.
  static const int trainingIndex = 0;
  static const int skillsIndex = 1;
  static const int homeIndex = 2;

  static const Set<String> _tabRoutes = <String>{
    AppRoutes.training,
    AppRoutes.skills,
  };

  static bool get isLoggedIn => Get.find<SessionService>().isLoggedIn.value;

  /// True when signed in. Otherwise opens the login page and returns false.
  static bool requireLogin() {
    if (isLoggedIn) return true;
    if (Get.currentRoute != AppRoutes.signIn) {
      Get.toNamed<void>(AppRoutes.signIn);
    }
    return false;
  }

  static bool routeExists(String route) =>
      AppPages.pages.any((page) => page.name == route);

  /// Any "open this page" button: login first, and pages that are not built
  /// yet show a short message instead of crashing on an unknown route.
  static void open(String route) {
    if (!requireLogin()) return;
    if (!routeExists(route)) {
      AppToast.info('Coming soon');
      return;
    }
    Get.toNamed<void>(route);
  }

  static void onTabSelected(int index) {
    if (index == homeIndex) {
      if (Get.currentRoute != AppRoutes.dashboard) {
        Get.offAllNamed<void>(AppRoutes.dashboard);
      }
      return;
    }

    if (!requireLogin()) return;

    if (index == trainingIndex) return _openTab(AppRoutes.training);
    if (index == skillsIndex) return _openTab(AppRoutes.skills);

    // Fun / Tracker: pages are not built yet.
    AppToast.info('Coming soon');
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

  /// The menu itself is open to everyone; its items ask signed-out users
  /// to log in.
  static void openMenu() => Get.toNamed<void>(AppRoutes.menu);
}
