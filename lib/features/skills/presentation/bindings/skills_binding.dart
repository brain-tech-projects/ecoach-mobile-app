import 'package:get/get.dart';

import 'package:ecoach_pro/features/skills/data/repositories/dummy_skills_repository.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skill_detail_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skill_list_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skills_controller.dart';

class SkillsBinding extends Bindings {
  SkillsBinding();

  @override
  void dependencies() {
    Get.lazyPut<SkillsRepository>(DummySkillsRepository.new);
    Get.put<SkillsController>(SkillsController(Get.find<SkillsRepository>()));
  }
}

class SkillListBinding extends Bindings {
  SkillListBinding();

  @override
  void dependencies() {
    Get.lazyPut<SkillsRepository>(DummySkillsRepository.new);
    Get.put<SkillListController>(SkillListController(Get.find<SkillsRepository>()));
  }
}

class SkillDetailBinding extends Bindings {
  SkillDetailBinding();

  @override
  void dependencies() {
    Get.lazyPut<SkillDetailController>(SkillDetailController.new);
  }
}
