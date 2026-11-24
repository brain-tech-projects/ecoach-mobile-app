import 'package:ecoach_pro/core/utils/role_extensions.dart';
import 'package:ecoach_pro/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/features/player/domain/notification_route.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repository);

  final PlayerRepository _repository;
  final RxList<AppNotification> items = <AppNotification>[].obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  /// Set true when the OS notification permission is denied (hook up your
  /// permission / FCM service). The banner can be dismissed.
  final RxBool permissionBlocked = false.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// Whether a tap on [item] goes somewhere (coach and player have different maps).
  bool canOpen(AppNotification item) => isCoachSession ? NotificationRoute.of(item) != null : item.kind.route != null;

  Future<void> load() async {
    // Coach: pull-to-refresh keeps the current list on screen instead of a full loader.
    final keepList = isCoachSession && items.isNotEmpty;
    if (!keepList) loading.value = true;
    errorMessage.value = null;
    try {
      items.assignAll(await _repository.fetchNotifications());
      // Opening the screen counts as reading them (best effort).
      _repository.markAllNotificationsRead().then((_) {
        if (isCoachSession && Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().unreadCount.value = 0; // header bell badge
        }
      }).catchError((Object _) {});
    } catch (error, stackTrace) {
      AppLogger.error('Notifications load failed', error: error, stackTrace: stackTrace);
      if (!keepList) errorMessage.value = 'Could not load notifications.';
    } finally {
      loading.value = false;
    }
  }

  void dismissBanner() => permissionBlocked.value = false;

  /// Tap on a row: open the screen the notification is about.
  void open(AppNotification item) {
    final route = NotificationRoute.of(item);
    if (route == null) return;
    Get.toNamed<void>(route, arguments: NotificationRoute.argumentsFor(route));
  }


}
