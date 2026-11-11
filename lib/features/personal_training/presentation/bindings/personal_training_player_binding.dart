import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/personal_training/presentation/controllers/personal_training_player_controller.dart';
import 'package:ecoach_pro/features/skills/data/repositories/api_skills_repository.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

class PersonalTrainingPlayerBinding extends Bindings {
  PersonalTrainingPlayerBinding();

  @override
  void dependencies() {
    Get.lazyPut<SkillsRepository>(
      () => ApiSkillsRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<PersonalTrainingPlayerController>(
      () => PersonalTrainingPlayerController(Get.find<SkillsRepository>()),
    );
  }
}
