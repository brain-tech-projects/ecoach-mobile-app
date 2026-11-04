import 'package:flutter/material.dart';

import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_nav_buttons.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_option_tile.dart';

/// One question page: "1/10" pill, question, A-D options, Previous / Next.
class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.isLast,
    required this.isBusy,
    required this.scale,
    required this.hPad,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
  });

  final QuizQuestion question;
  final int index;
  final int total;
  final int? selected;
  final bool isLast;
  final bool isBusy;
  final double scale;
  final double hPad;
  final ValueChanged<int> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const String letters = 'ABCDEFGHIJ';

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey<int>(index),
            padding: EdgeInsets.fromLTRB(hPad, 28.3 * s, hPad, 16 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    label: 'Question ${index + 1} of $total',
                    child: Container(
                      height: 31 * s,
                      constraints: BoxConstraints(minWidth: 68 * s),
                      padding: EdgeInsets.symmetric(horizontal: 14 * s),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(31 * s)),
                      child: Text('${index + 1}/$total', style: FunTextStyles.counter.copyWith(fontSize: 16 * s)),
                    ),
                  ),
                ),
                SizedBox(height: 22.5 * s),
                Text(question.text, style: FunTextStyles.question.copyWith(fontSize: 16 * s)),
                SizedBox(height: 27.7 * s),
                for (var i = 0; i < question.options.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 14.7 * s),
                  QuizOptionTile(
                    letter: letters[i % letters.length],
                    text: question.options[i],
                    scale: s,
                    state: selected == i ? QuizOptionState.selected : QuizOptionState.idle,
                    onTap: () => onSelect(i),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 21.7 * s),
          child: QuizNavButtons(
            scale: s,
            nextLabel: isLast ? 'Submit' : 'Next',
            nextEnabled: selected != null,
            isBusy: isBusy,
            onPrevious: onPrevious,
            onNext: onNext,
          ),
        ),
      ],
    );
  }
}
