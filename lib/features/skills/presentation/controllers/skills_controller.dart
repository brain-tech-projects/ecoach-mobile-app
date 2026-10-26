import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

/// "Skills" tab - the skill areas grid.
class SkillsController extends GetxController {
  SkillsController(this._repository);

  final SkillsRepository _repository;

  final RxList<SkillCategory> categories = <SkillCategory>[].obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    errorMessage.value = null;
    try {
      categories.assignAll(await _repository.fetchCategories());
    } catch (error, stackTrace) {
      AppLogger.error('Skills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the skills.';
    }
  }

  void openCategory(SkillCategory category) =>
      Get.toNamed<void>(AppRoutes.skillList, arguments: category);
}
