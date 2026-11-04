import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_review_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_option_tile.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_question_view.dart';

/// Read-only list of every question with the user's and the right answer.
class QuizReviewPage extends GetView<QuizReviewController> {
  const QuizReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    final quiz = controller.args.quiz;
    final result = controller.args.result;
    return SubPageScaffold(
      title: quiz.title,
      navIndex: MainNav.funIndex,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 28.3 * s, hPad, 24 * s),
        itemCount: quiz.questions.length,
        itemBuilder: (context, i) {
          final q = quiz.questions[i];
          final picked = i < result.selected.length ? result.selected[i] : null;
          final right = (i < result.correctAnswers.length ? result.correctAnswers[i] : null) ?? q.correctIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: 28 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('${i + 1}. ${q.text}', style: FunTextStyles.question.copyWith(fontSize: 16 * s)),
                SizedBox(height: 14 * s),
                for (var o = 0; o < q.options.length; o++) ...<Widget>[
                  if (o > 0) SizedBox(height: 10 * s),
                  QuizOptionTile(
                    letter: QuizQuestionView.letters[o % QuizQuestionView.letters.length],
                    text: q.options[o],
                    scale: s,
                    state: o == right
                        ? QuizOptionState.correct
                        : (o == picked ? QuizOptionState.incorrect : QuizOptionState.idle),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
