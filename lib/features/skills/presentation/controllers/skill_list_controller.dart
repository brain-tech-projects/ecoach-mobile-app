import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/drill_actions.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/notes_dialog.dart';

/// Drills of one skill area.
class SkillListController extends GetxController {
  SkillListController(this._repository);

  final SkillsRepository _repository;

  /// The skill area to list. Opened without one (the Home "What's New &
  /// Open Access" tile), it shows the free drills.
  final SkillCategory category = Get.arguments is SkillCategory
      ? Get.arguments as SkillCategory
      : SkillCategory.openAccess;

  final RxList<Drill> drills = <Drill>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = category.isOpenAccess
          ? await _repository.fetchFreeDrills()
          : category.isAll
          ? await _repository.fetchAllDrills()
          : await _repository.fetchDrills(category.id);
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }
      drills.assignAll(res.data ?? const <Drill>[]);
    } catch (error, stackTrace) {
      AppLogger.error('Drills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the drills.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openDrill(Drill drill) async {
    await Get.toNamed<void>(AppRoutes.skillDetail, arguments: drill);
    // Views / completion may have changed.
    load();
  }

  void _replace(Drill updated) {
    final i = drills.indexWhere((d) => d.id == updated.id);
    if (i != -1) drills[i] = updated;
  }

  Future<void> addToPersonalSession(Drill drill) async {
    final updated = await DrillActions.toggleSession(_repository, drill);
    if (updated != null) _replace(updated);
  }

  Future<void> addToMySkills(Drill drill) async {
    final updated = await DrillActions.toggleMySkills(_repository, drill);
    if (updated != null) _replace(updated);
  }

  void addNote(Drill drill) => showNotesDialog(drill);
}
