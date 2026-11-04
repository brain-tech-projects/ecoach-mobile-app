import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';

enum QuizOptionState { idle, selected, correct, incorrect }

/// "A  answer text" row. [onTap] null = read-only (review).
class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.scale,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  final String letter;
  final String text;
  final double scale;
  final QuizOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final good = state == QuizOptionState.selected || state == QuizOptionState.correct;
    final bad = state == QuizOptionState.incorrect;
    final fill = good
        ? FunColors.optionSelected
        : bad
        ? const Color(0x33E5283C)
        : AppColors.card;
    final border = good
        ? AppColors.accent
        : bad
        ? AppColors.error
        : AppColors.cardBorder;
    final badgeFill = good
        ? AppColors.accent
        : bad
        ? AppColors.error
        : AppColors.background;
    final badgeBorder = bad ? AppColors.error : AppColors.accent;

    return Semantics(
      button: onTap != null,
      selected: good,
      label: 'Option $letter: $text',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: BoxConstraints(minHeight: 51.3 * s),
          padding: EdgeInsets.fromLTRB(11.2 * s, 10 * s, 12 * s, 10 * s),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(8.7 * s),
            border: Border.all(color: border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 31.3 * s,
                height: 31.3 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeFill,
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  letter,
                  style: FunTextStyles.letter.copyWith(
                    fontSize: 15 * s,
                    color: state == QuizOptionState.selected || state == QuizOptionState.correct
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16.8 * s),
              Expanded(child: Text(text, style: FunTextStyles.option.copyWith(fontSize: 15 * s))),
            ],
          ),
        ),
      ),
    );
  }
}
