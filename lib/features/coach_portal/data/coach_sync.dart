import 'dart:async';

import 'package:get/get.dart';

/// App-wide "coach data changed" signal.
///
/// Every successful coach action ([coachRun]) calls [bump]. A controller that
/// uses [CoachAutoRefresh] reloads (silently, at most once) when it is on
/// screen, or the next time its screen becomes visible again - so Home, Teams,
/// Players, Programs ... always show fresh data without manual refresh and
/// without extra API calls for screens nobody is looking at.
abstract final class CoachSync {
  static final RxInt revision = 0.obs;
  static final RxString currentRoute = ''.obs;

  static void bump() => revision.value++;

  /// Hooked into `GetMaterialApp.routingCallback`.
  static void onRouting(Routing? routing) {
    final name = routing?.current;
    if (name != null && name.isNotEmpty) currentRoute.value = name;
  }
}

mixin CoachAutoRefresh on GetxController {
  /// Route name of the screen this controller belongs to.
  String get syncRoute;

  /// Silent reload (no full-screen loader).
  Future<void> syncReload();

  int _loadedRevision = 0;
  final List<Worker> _syncWorkers = <Worker>[];

  /// Call at the START of every load so a reload already in flight is not repeated.
  void markLoaded() => _loadedRevision = CoachSync.revision.value;

  void startAutoRefresh() {
    _loadedRevision = CoachSync.revision.value;
    _syncWorkers
      ..add(ever<int>(CoachSync.revision, (_) => _reloadIfStale()))
      ..add(ever<String>(CoachSync.currentRoute, (_) => _reloadIfStale()));
  }

  void stopAutoRefresh() {
    for (final w in _syncWorkers) {
      w.dispose();
    }
    _syncWorkers.clear();
  }

  void _reloadIfStale() {
    if (CoachSync.currentRoute.value != syncRoute) return;
    if (_loadedRevision == CoachSync.revision.value) return;
    // Small delay: the screen's own post-action reload (dialog closing etc.)
    // runs first and marks the data as loaded, so we never fetch twice.
    Timer(const Duration(milliseconds: 350), () {
      if (isClosed || _loadedRevision == CoachSync.revision.value) return;
      if (CoachSync.currentRoute.value != syncRoute) return;
      markLoaded();
      syncReload();
    });
  }
}