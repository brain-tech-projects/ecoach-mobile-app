import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/fun/data/repositories/api_fun_repository.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenge_detail_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenges_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/fun_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_groups_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_list_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_play_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_review_controller.dart';

void _repo() => Get.lazyPut<FunRepository>(
  () => ApiFunRepository(Get.find<ApiService>()),
);

class FunBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<FunController>(FunController.new);
}

class ChallengesBinding extends Bindings {
  @override
  void dependencies() {
    _repo();
    Get.lazyPut<ChallengesController>(
      () => ChallengesController(Get.find<FunRepository>()),
    );
  }
}

class ChallengeDetailBinding extends Bindings {
  @override
  void dependencies() {
    _repo();
    Get.lazyPut<ChallengeDetailController>(
      () => ChallengeDetailController(Get.find<FunRepository>()),
    );
  }
}

class QuizGroupsBinding extends Bindings {
  @override
  void dependencies() {
    _repo();
    Get.lazyPut<QuizGroupsController>(
      () => QuizGroupsController(Get.find<FunRepository>()),
    );
  }
}

class QuizListBinding extends Bindings {
  @override
  void dependencies() {
    _repo();
    Get.lazyPut<QuizListController>(
      () => QuizListController(Get.find<FunRepository>()),
    );
  }
}

class QuizPlayBinding extends Bindings {
  @override
  void dependencies() {
    _repo();
    Get.lazyPut<QuizPlayController>(
      () => QuizPlayController(Get.find<FunRepository>()),
    );
  }
}

class QuizReviewBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<QuizReviewController>(QuizReviewController.new);
}
