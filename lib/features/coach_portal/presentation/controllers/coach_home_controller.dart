import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

/// Stats of the coach home. Banners / unread count / header come from the
/// existing DashboardController.
class CoachHomeController extends GetxController {
  final Rx<CoachHomeStats> stats = const CoachHomeStats().obs;
  final RxBool loading = false.obs;

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onInit() {
    super.onInit();
    ensureCoachPortalRepository();
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    if (loading.value) return;
    loading.value = true;
    try {
      stats.value = await _repo.fetchHome();
    } catch (e, st) {
      AppLogger.error('Coach home load failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  void openTeams() => Get.toNamed<void>(AppRoutes.coachTeams);
  void openPlayers() => Get.toNamed<void>(AppRoutes.coachPlayers);
  void openPrograms() => Get.toNamed<void>(AppRoutes.coachPrograms);

  Future<void> createTraining() async {
    await Get.toNamed<void>(AppRoutes.coachAddTraining);
    load();
  }

  Future<void> notify() => CoachDialogs.notifyPlayers();
}
