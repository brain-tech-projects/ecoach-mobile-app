import 'package:ecoach_pro/features/fun/data/repositories/dummy_fun_repository.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenge_detail_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenges_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/fun_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_groups_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_list_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_play_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_review_controller.dart';
import 'package:get/get.dart';

// Swap DummyFunRepository for ApiFunRepository here when the API is ready.
void _repo() => Get.lazyPut<FunRepository>(DummyFunRepository.new);

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
  void dependencies() =>
      Get.lazyPut<ChallengeDetailController>(ChallengeDetailController.new);
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
