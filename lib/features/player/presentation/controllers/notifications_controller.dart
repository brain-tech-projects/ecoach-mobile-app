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

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      items.assignAll(await _repository.fetchNotifications());
      // Opening the screen counts as reading them (best effort).
      _repository.markAllNotificationsRead().catchError((Object _) {});
    } catch (error, stackTrace) {
      AppLogger.error('Notifications load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load notifications.';
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

  void onTap(AppNotification item) {}
}
