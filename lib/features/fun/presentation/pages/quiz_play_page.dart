import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_play_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_intro_view.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_question_view.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_result_view.dart';

/// Start screen -> questions -> result, all under one route.
class QuizPlayPage extends GetView<QuizPlayController> {
  const QuizPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    return SubPageScaffold(
      title: controller.summary.title,
      navIndex: MainNav.funIndex,
      body: Obx(() {
        if (controller.isLoading.value) return const FunLoader();
        final error = controller.errorMessage.value;
        final quiz = controller.quiz.value;
        if (error != null || quiz == null) {
          return FunErrorView(message: error ?? 'Could not load this quiz.', onRetry: controller.load, scale: s);
        }
        final result = controller.result.value;
        if (result != null) {
          return QuizResultView(
            result: result,
            scale: s,
            hPad: hPad,
            onReview: controller.openReview,
            onDone: controller.done,
            onAnother: controller.restart,
          );
        }
        if (!controller.started.value) {
          return QuizIntroView(
            title: quiz.title,
            questionCount: quiz.questions.length,
            imageUrl: quiz.imageUrl,
            scale: s,
            hPad: hPad,
            onStart: controller.start,
          );
        }
        final i = controller.index.value;
        return QuizQuestionView(
          question: quiz.questions[i],
          index: i,
          total: quiz.questions.length,
          selected: controller.answers[i],
          isLast: controller.isLast,
          isBusy: controller.isSubmitting.value,
          scale: s,
          hPad: hPad,
          onSelect: controller.select,
          onPrevious: controller.previous,
          onNext: controller.next,
        );
      }),
    );
  }
}
