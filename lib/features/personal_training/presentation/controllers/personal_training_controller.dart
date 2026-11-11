import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/personal_training/domain/entities/personal_training_player_args.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// "Personal Training Session": the drills the player added from Skills.
class PersonalTrainingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<Drill> drills = <Drill>[].obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _api.getPersonalTrainingSession();
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }
      // Everything here is in the session, so the menu offers "Remove".
      drills.assignAll(
        (res.data ?? const <Drill>[]).map(
          (d) => d.copyWith(canAddToSession: false),
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Personal session load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your session.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> openDrill(Drill drill) async {
    await Get.toNamed<void>(AppRoutes.skillDetail, arguments: drill);
    load();
  }

  /// Plays the whole session from the first video (Previous / Next, auto-advance).
  void playAll() {
    if (drills.isEmpty) return;
    Get.toNamed<void>(
      AppRoutes.personalTrainingPlayer,
      arguments: PersonalTrainingPlayerArgs(drills: drills.toList()),
    );
  }

  void addSkills() => MainNav.onTabSelected(MainNav.skillsIndex);

  Future<void> remove(Drill drill) async {
    final res = await _api.setVideoInPersonalSession(drill.id, add: false);
    if (res.isSubscriptionRequired) {
      Get.toNamed<void>(AppRoutes.subscription);
      return;
    }
    if (!res.success) {
      AppToast.error(res.message);
      return;
    }
    drills.removeWhere((d) => d.id == drill.id);
    AppToast.success(res.message);
  }
}
