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

  /// Bumped on every load: an older, slower response never overwrites the
  /// list of the skill area that is on screen.
  int _loadToken = 0;
  bool _opening = false;

  Future<void> load() async {
    final token = ++_loadToken;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = category.isOpenAccess
          ? await _repository.fetchFreeDrills()
          : category.isAll
          ? await _repository.fetchAllDrills()
          : await _repository.fetchDrills(category.id);
      if (token != _loadToken || isClosed) return;
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }
      drills.assignAll(_onlyThisArea(res.data ?? const <Drill>[]));
    } catch (error, stackTrace) {
      if (token != _loadToken || isClosed) return;
      AppLogger.error('Drills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the drills.';
    } finally {
      if (token == _loadToken) isLoading.value = false;
    }
  }

  /// A specific skill area (Dribbling, Shooting...) only shows its own
  /// drills. When the API tags drills with their area, any stray drill of
  /// another area is dropped; All Skills / My Skills show everything.
  List<Drill> _onlyThisArea(List<Drill> list) {
    if (category.isAll || category.isOpenAccess) return list;
    return list
        .where((d) => d.categoryId == 0 || d.categoryId == category.id)
        .toList(growable: false);
  }

  Future<void> openDrill(Drill drill) async {
    if (_opening) return; // ignore a double tap
    _opening = true;
    try {
      await Get.toNamed<void>(AppRoutes.skillDetail, arguments: drill);
    } finally {
      _opening = false;
    }
    // Views / completion may have changed.
    if (!isClosed) load();
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
