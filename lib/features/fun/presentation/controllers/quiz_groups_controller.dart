import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';

class QuizGroupsController extends GetxController {
  QuizGroupsController(this._repository);

  final FunRepository _repository;

  final RxList<QuizGroup> groups = <QuizGroup>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final res = await _repository.fetchQuizGroups();
    if (res.isSubscriptionRequired) {
      Get.offNamed<void>(AppRoutes.subscription);
      return;
    }
    if (res.success && res.data != null) {
      groups.assignAll(res.data!);
    } else {
      errorMessage.value = res.message.isEmpty
          ? 'Could not load quizzes.'
          : res.message;
    }
    isLoading.value = false;
  }

  void open(QuizGroup g) =>
      Get.toNamed<void>(AppRoutes.quizList, arguments: g);
}
