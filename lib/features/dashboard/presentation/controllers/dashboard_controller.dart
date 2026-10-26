import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final DashboardRepository _repository;

  final Rxn<DashboardData> data = Rxn<DashboardData>();
  final RxnString errorMessage = RxnString();

  /// Bottom-nav tab (0 Training, 1 Skills, 2 Home, 3 Fun, 4 Tracker).
  final RxInt selectedTab = 2.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    errorMessage.value = null;
    try {
      data.value = await _repository.fetchDashboard();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Dashboard load failed',
        error: error,
        stackTrace: stackTrace,
      );
      errorMessage.value = 'Could not load your dashboard.';
    }
  }

  /// Header, stat tiles and program rows all open the login / sign-up page.
  void openAuth() => Get.toNamed<void>(AppRoutes.signIn);

  // Wired later.
  void onJoinNow() {}
  void onTakeTour() {}
  void onInstallApp() {}

  void onStatTap(DashboardStat stat) {
    switch (stat.label) {
      case 'Matches tracked':
        Get.toNamed<void>(AppRoutes.ratingTracker);
        break;
      case 'Reward Points':
      case 'Trophies':
        Get.toNamed<void>(AppRoutes.trophyRoom);
        break;
      default:
        openAuth();
    }
  }

  /// Signed-out users are sent to login / sign-up for tabs other than Home.
  void onNavTap(int index) => MainNav.onTabSelected(index);

  void openMenu() => MainNav.openMenu();
}
