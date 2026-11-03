import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/menu/domain/entities/menu_item.dart';

class SideMenuController extends GetxController {
  final SessionService session = Get.find<SessionService>();
  final ApiService _api = Get.find<ApiService>();

  final RxInt unreadCount = 0.obs;

  @override
  void onReady() {
    super.onReady();
    _loadUnread();
  }

  bool get isLoggedIn => session.isLoggedIn.value;

  Future<void> _loadUnread() async {
    if (!isLoggedIn) return;
    final res = await _api.getUnreadCount();
    if (res.success) unreadCount.value = res.data ?? 0;
  }

  void close() => Get.back<void>();

  /// The menu is replaced by the destination, so "back" returns to the page
  /// the menu was opened from.
  void openItem(MenuItem item) {
    // Signed out: every item asks for login first (back returns to the menu).
    if (!MainNav.requireLogin()) return;

    switch (item.action) {
      case MenuAction.logout:
        confirmLogout();
        return;
      case MenuAction.installApp:
        AppToast.info('Coming soon');
        return;
      case MenuAction.navigate:
        if (item.route.isEmpty || !MainNav.routeExists(item.route)) {
          AppToast.info('Coming soon');
          return;
        }
        Get.offNamed<void>(item.route);
    }
  }

  /// Tap on the signed-out profile block.
  void openLogin() => Get.toNamed<void>(AppRoutes.signIn);

  // Quick-action row under the name.
  void openRewards() => MainNav.open(AppRoutes.trophyRoom);
  void openEditProfile() => AppToast.info('Coming soon');
  void openMessages() => AppToast.info('Coming soon');
  void openNotifications() => AppToast.info('Coming soon');

  Future<void> confirmLogout() async {
    final yes = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.selectGreen),
            ),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _api.logout();
    Get.offAllNamed<void>(AppRoutes.dashboard);
  }
}
