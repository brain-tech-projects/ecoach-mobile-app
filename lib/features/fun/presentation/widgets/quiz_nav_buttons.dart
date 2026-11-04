import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';

/// "Previous" (outlined) and "Next" (filled / disabled outline) buttons.
class QuizNavButtons extends StatelessWidget {
  const QuizNavButtons({
    super.key,
    required this.scale,
    required this.nextLabel,
    required this.nextEnabled,
    required this.isBusy,
    required this.onPrevious,
    required this.onNext,
  });

  final double scale;
  final String nextLabel;
  final bool nextEnabled;
  final bool isBusy;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(8 * s);
    final enabled = nextEnabled && !isBusy;
    return Row(
      children: <Widget>[
        Expanded(
          child: _Btn(
            label: 'Previous',
            height: 44 * s,
            radius: radius,
            border: FunColors.previousButton,
            textColor: FunColors.previousButton,
            fontSize: 16 * s,
            onTap: isBusy ? null : onPrevious,
          ),
        ),
        SizedBox(width: 8 * s),
        Expanded(
          child: _Btn(
            label: nextLabel,
            height: 44 * s,
            radius: radius,
            fill: enabled ? AppColors.accent : null,
            border: enabled ? AppColors.accent : FunColors.disabledOutline,
            textColor: enabled ? Colors.black : FunColors.disabledOutline,
            fontSize: 16 * s,
            busy: isBusy,
            onTap: enabled ? onNext : null,
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.height,
    required this.radius,
    required this.border,
    required this.textColor,
    required this.fontSize,
    required this.onTap,
    this.fill,
    this.busy = false,
  });

  final String label;
  final double height;
  final BorderRadius radius;
  final Color? fill;
  final Color border;
  final Color textColor;
  final double fontSize;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: fill, borderRadius: radius, border: Border.all(color: border)),
        child: busy
            ? SizedBox(
                width: fontSize,
                height: fontSize,
                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : Text(label, style: FunTextStyles.button.copyWith(fontSize: fontSize, color: textColor)),
      ),
    ),
  );
}
