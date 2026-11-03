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
      final res = await _repository.fetchCategories();
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }
      // API areas + the static "All Skills" tile at the end.
      categories.assignAll(<SkillCategory>[
        ...(res.data ?? const <SkillCategory>[]).where(
          (c) => c.name.toLowerCase() != 'all skills',
        ),
        SkillCategory.all,
      ]);
    } catch (error, stackTrace) {
      AppLogger.error('Skills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the skills.';
    } finally {
      isLoading.value = false;
    }
  }

  void openCategory(SkillCategory category) =>
      Get.toNamed<void>(AppRoutes.skillList, arguments: category);
}
