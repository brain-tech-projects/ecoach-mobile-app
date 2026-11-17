import 'package:get/get.dart';

import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_building_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_home_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_player_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_result_controller.dart';

class AiHomeBinding extends Bindings {
  @override
  void dependencies() {
    ensureAiSessionRepository();
    Get.lazyPut<AiHomeController>(AiHomeController.new);
  }
}

class AiBuildingBinding extends Bindings {
  @override
  void dependencies() {
    ensureAiSessionRepository();
    Get.lazyPut<AiBuildingController>(AiBuildingController.new);
  }
}

class AiResultBinding extends Bindings {
  @override
  void dependencies() {
    ensureAiSessionRepository();
    Get.lazyPut<AiResultController>(AiResultController.new);
  }
}

class AiPlayerBinding extends Bindings {
  @override
  void dependencies() {
    ensureAiSessionRepository();
    Get.lazyPut<AiPlayerController>(AiPlayerController.new);
  }
}
