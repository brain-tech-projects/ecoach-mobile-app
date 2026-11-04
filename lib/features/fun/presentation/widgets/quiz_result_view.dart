import 'package:flutter/material.dart';

import 'package:ecoach_pro/features/fun/data/fun_assets.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_intro_view.dart';

/// "Quiz Complete - Score : 5 out of 50".
class QuizResultView extends StatelessWidget {
  const QuizResultView({
    super.key,
    required this.result,
    required this.scale,
    required this.hPad,
    required this.onReview,
    required this.onDone,
    required this.onAnother,
  });

  final QuizResult result;
  final double scale;
  final double hPad;
  final VoidCallback onReview;
  final VoidCallback onDone;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16 * s),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        FunAssets.quizComplete,
                        width: 100 * s,
                        height: 100 * s,
                        excludeFromSemantics: true,
                      ),
                    ),
                    SizedBox(height: 27 * s),
                    Text('Quiz Complete', textAlign: TextAlign.center, style: FunTextStyles.resultTitle.copyWith(fontSize: 25 * s)),
                    SizedBox(height: 14 * s),
                    Text(
                      'Score : ${result.score} out of ${result.maxScore}',
                      textAlign: TextAlign.center,
                      style: FunTextStyles.resultScore.copyWith(fontSize: 16 * s),
                    ),
                    SizedBox(height: 14 * s),
                    _TextAction(label: 'Review your answers', style: FunTextStyles.resultLink.copyWith(fontSize: 16 * s), scale: s, onTap: onReview),
                    SizedBox(height: 8 * s),
                    FunPrimaryButton(label: 'Done', scale: s, onTap: onDone),
                    SizedBox(height: 4 * s),
                    _TextAction(
                      label: 'Make Another Submission',
                      style: FunTextStyles.resultAnother.copyWith(fontSize: 16 * s),
                      scale: s,
                      onTap: onAnother,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.style, required this.scale, required this.onTap});

  final String label;
  final TextStyle style;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 44 * scale),
        child: Center(child: Text(label, textAlign: TextAlign.center, style: style)),
      ),
    ),
  );
}
