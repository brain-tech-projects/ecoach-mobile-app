import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// "— WORLD CUP QUIZ —  10 Questions  [Start]".
class QuizIntroView extends StatelessWidget {
  const QuizIntroView({
    super.key,
    required this.title,
    required this.questionCount,
    required this.scale,
    required this.hPad,
    required this.onStart,
    this.imageUrl,
  });

  final String title;
  final int questionCount;
  final double scale;
  final double hPad;
  final String? imageUrl;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget line() => Container(
      width: 40 * s,
      height: 3 * s,
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2 * s)),
    );
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (imageUrl != null) ...<Widget>[
                  SizedBox(
                    height: 200 * s,
                    child: ClipRRect(borderRadius: BorderRadius.circular(12 * s), child: FunImage(imageUrl!)),
                  ),
                  SizedBox(height: 24 * s),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    line(),
                    SizedBox(width: 16 * s),
                    Flexible(
                      child: Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: FunTextStyles.introTitle.copyWith(fontSize: 21.5 * s),
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    line(),
                  ],
                ),
                SizedBox(height: 4.5 * s),
                Text(
                  '$questionCount Questions',
                  textAlign: TextAlign.center,
                  style: FunTextStyles.introSub.copyWith(fontSize: 16 * s),
                ),
                SizedBox(height: 48 * s),
                _PrimaryButton(label: 'Start', scale: s, onTap: onStart),
                SizedBox(height: 28 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width accent button (Start / Done).
class FunPrimaryButton extends _PrimaryButton {
  const FunPrimaryButton({super.key, required super.label, required super.scale, required super.onTap});
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({super.key, required this.label, required this.scale, required this.onTap});

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 43.7 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8 * scale)),
        child: Text(label, style: FunTextStyles.button.copyWith(fontSize: 16 * scale, color: Colors.black)),
      ),
    ),
  );
}
