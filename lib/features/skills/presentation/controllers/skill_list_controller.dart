import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

/// Drills of one skill area.
class SkillListController extends GetxController {
  SkillListController(this._repository);

  final SkillsRepository _repository;

  final SkillCategory category = Get.arguments as SkillCategory;

  final RxList<Drill> drills = <Drill>[].obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    errorMessage.value = null;
    try {
      drills.assignAll(await _repository.fetchDrills(category.id));
    } catch (error, stackTrace) {
      AppLogger.error('Drills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the drills.';
    }
  }

  void openDrill(Drill drill) =>
      Get.toNamed<void>(AppRoutes.skillDetail, arguments: drill);

  // "⋮" menu actions - wired to the API later.
  void addToPersonalSession(Drill drill) {}
  void addToMySkills(Drill drill) {}
  void addNote(Drill drill) {}
}
