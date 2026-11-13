import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';

/// Coach bottom tabs: 0 Teams, 1 Players, 2 Home, 3 Program, 4 Profile.
abstract final class CoachNav {
  static const int teamsIndex = 0;
  static const int playersIndex = 1;
  static const int homeIndex = 2;
  static const int programIndex = 3;
  static const int profileIndex = 4;

  static const List<String> _roots = <String>[
    AppRoutes.coachTeams,
    AppRoutes.coachPlayers,
    AppRoutes.dashboard,
    AppRoutes.coachPrograms,
    AppRoutes.myProfile,
  ];

  /// Inner pages -> the tab they belong to (tapping that tab returns to its root).
  static const Map<String, int> _children = <String, int>{
    AppRoutes.coachTeamForm: teamsIndex,
    AppRoutes.coachPlayerDetail: playersIndex,
    AppRoutes.coachAddTraining: programIndex,
  };

  static void onTabSelected(int index) {
    if (!MainNav.requireLogin()) return;
    final current = Get.currentRoute;

    if (index == homeIndex) {
      if (current != AppRoutes.dashboard) {
        Get.offAllNamed<void>(AppRoutes.dashboard);
      }
      return;
    }

    final root = _roots[index];
    if (current == root) return;
    if (_children[current] == index) {
      Get.until((route) => route.settings.name == root || route.isFirst);
      return;
    }
    final isTabPage = _roots.indexOf(current) >= 0 && current != AppRoutes.dashboard;
    if (isTabPage) {
      Get.offNamed<void>(root);
    } else {
      Get.toNamed<void>(root);
    }
  }
}
