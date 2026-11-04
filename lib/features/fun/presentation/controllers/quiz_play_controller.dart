import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';

/// One quiz run: start screen -> questions -> result.
class QuizPlayController extends GetxController {
  QuizPlayController(this._repository);

  final FunRepository _repository;
  final QuizSummary summary = Get.arguments as QuizSummary;

  final Rxn<Quiz> quiz = Rxn<Quiz>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  final RxBool started = false.obs;
  final RxInt index = 0.obs;
  final RxList<int?> answers = <int?>[].obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<QuizResult> result = Rxn<QuizResult>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final res = await _repository.fetchQuiz(summary);
    if (res.isSubscriptionRequired) {
      Get.offNamed<void>(AppRoutes.subscription);
      return;
    }
    final q = res.data;
    if (res.success && q != null && q.questions.isNotEmpty) {
      quiz.value = q;
      answers.assignAll(List<int?>.filled(q.questions.length, null));
    } else {
      errorMessage.value = res.message.isEmpty
          ? 'Could not load this quiz.'
          : res.message;
    }
    isLoading.value = false;
  }

  int get total => quiz.value?.questions.length ?? 0;
  bool get isLast => index.value >= total - 1;
  bool get hasAnswer => index.value < answers.length && answers[index.value] != null;

  void start() => started.value = true;

  void select(int option) {
    if (isSubmitting.value) return;
    answers[index.value] = option;
  }

  void previous() {
    if (index.value > 0) index.value--;
  }

  Future<void> next() async {
    if (!hasAnswer || isSubmitting.value) return;
    if (isLast) {
      await submit();
    } else {
      index.value++;
    }
  }

  Future<void> submit() async {
    final q = quiz.value;
    if (q == null || isSubmitting.value) return;
    isSubmitting.value = true;
    final res = await _repository.submitQuiz(q, answers.toList());
    isSubmitting.value = false;
    if (res.success && res.data != null) {
      result.value = res.data;
      AppToast.success(
        res.message.isEmpty ? 'Quiz submitted successfully' : res.message,
      );
    } else if (res.isSubscriptionRequired) {
      Get.toNamed<void>(AppRoutes.subscription);
    } else {
      AppToast.error(
        res.message.isEmpty ? 'Could not submit the quiz.' : res.message,
      );
    }
  }

  /// "Make Another Submission": start again from question 1.
  void restart() {
    result.value = null;
    answers.assignAll(List<int?>.filled(total, null));
    index.value = 0;
    started.value = true;
  }

  void openReview() {
    final q = quiz.value;
    final r = result.value;
    if (q == null || r == null) return;
    Get.toNamed<void>(
      AppRoutes.quizReview,
      arguments: QuizReviewArgs(quiz: q, result: r),
    );
  }

  void done() => Get.back<void>();
}
