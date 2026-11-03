import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/dashboard/data/models/banner_model.dart';
import 'package:ecoach_pro/features/dashboard/data/models/dashboard_details.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/program.dart';
import 'package:ecoach_pro/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Home page for both states:
///  * signed out: static welcome content, every action opens login
///  * signed in: banners, stats and unread count from the API
class DashboardController extends GetxController {
  DashboardController(this._repository);

  final DashboardRepository _repository;
  final SessionService session = Get.find<SessionService>();
  final ApiService _api = Get.find<ApiService>();

  // Signed-out content
  final Rxn<DashboardData> data = Rxn<DashboardData>();
  final RxnString errorMessage = RxnString();

  // Signed-in content
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final Rxn<DashboardDetails> details = Rxn<DashboardDetails>();
  final RxInt unreadCount = 0.obs;
  final RxBool memberLoading = false.obs;

  /// Bottom-nav tab (0 Training, 1 Skills, 2 Home, 3 Fun, 4 Tracker).
  final RxInt selectedTab = 2.obs;

  bool get isLoggedIn => session.isLoggedIn.value;

  @override
  void onReady() {
    super.onReady();
    load();
    loadMember();
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

  /// Banners + stats + unread count (pull to refresh calls this too).
  Future<void> loadMember() async {
    if (!isLoggedIn || memberLoading.value) return;
    memberLoading.value = true;
    try {
      // Start all three requests, then wait for them.
      final bannersCall = _api.getBanners();
      final detailsCall = _api.getDetails();
      final unreadCall = _api.getUnreadCount();

      final bannersRes = await bannersCall;
      final detailsRes = await detailsCall;
      final unreadRes = await unreadCall;

      if (bannersRes.success) banners.assignAll(bannersRes.data ?? const []);
      if (detailsRes.success) details.value = detailsRes.data;
      if (unreadRes.success) unreadCount.value = unreadRes.data ?? 0;

      if (!detailsRes.success && detailsRes.statusCode != 401) {
        AppToast.error(detailsRes.message);
      }
    } finally {
      memberLoading.value = false;
    }
  }

  /// The four tiles of "Your Stats".
  List<DashboardStat> get memberStats {
    final d = details.value;
    return <DashboardStat>[
      DashboardStat(
        iconAsset: AppAssets.statClock,
        value: '${d?.trackers ?? 0}',
        label: 'Matches tracked',
      ),
      DashboardStat(
        iconAsset: AppAssets.statTrophy,
        value: '${d?.trophies ?? 0}',
        label: 'Trophies',
      ),
      DashboardStat(
        iconAsset: AppAssets.statCoin,
        value: (d?.points ?? 0).toStringAsFixed(2),
        label: 'Reward Points',
      ),
      DashboardStat(
        iconAsset: AppAssets.statClip,
        value: '${d?.streak ?? 0}/7',
        label: 'Training streak in last 7 days',
      ),
    ];
  }

  /// "You collected N points this month so far".
  String get monthlyPointsText {
    final v = details.value?.monthlyPoints ?? 0;
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }

  /// Signed out: header, stat tiles and program rows open login / sign-up.
  void openAuth() => MainNav.requireLogin();

  void onProgramTap(Program program) {
    final route = program.route;
    if (route == null) {
      if (MainNav.requireLogin()) AppToast.info('Coming soon');
      return;
    }
    MainNav.open(route);
  }

  void onStatTap(DashboardStat stat) {
    switch (stat.label) {
      case 'Matches tracked':
        MainNav.open(AppRoutes.ratingTracker);
        break;
      case 'Trophies':
        // "My Trophies" tab of the trophies page.
        if (MainNav.requireLogin()) {
          Get.toNamed<void>(AppRoutes.allTrophy, arguments: 1);
        }
        break;
      case 'Reward Points':
        MainNav.open(AppRoutes.trophyRoom);
        break;
      default:
        MainNav.requireLogin();
    }
  }

  void onEarnPoints() => MainNav.open(AppRoutes.trophyRoom);
  void onRedeemPoints() => MainNav.open(AppRoutes.trophyRoom);
  void onBellTap() {
    if (MainNav.requireLogin()) AppToast.info('Coming soon');
  }

  // Wired later.
  void onJoinNow() => MainNav.requireLogin();
  void onTakeTour() {}
  void onInstallApp() {}

  void onNavTap(int index) => MainNav.onTabSelected(index);

  void openMenu() => MainNav.openMenu();
}
