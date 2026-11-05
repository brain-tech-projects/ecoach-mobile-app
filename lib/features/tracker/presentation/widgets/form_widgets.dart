import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';

TextStyle _q(double s) => TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 17 * s,
      height: 1.3,
      color: AppColors.white,
    );

BoxDecoration _cardBox(double s) => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20 * s),
      border: Border.all(color: AppColors.cardBorder),
    );

/// White "3/13" pill.
class StepPill extends StatelessWidget {
  const StepPill({super.key, required this.step, required this.total, required this.scale});

  final int step;
  final int total;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'Step $step of $total',
        child: ExcludeSemantics(
          child: Container(
            height: 31 * s,
            padding: EdgeInsets.symmetric(horizontal: 20.3 * s),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20 * s)),
            child: Text(
              '$step/$total',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17 * s,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Photo + question (+ small hint) card.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.step, required this.scale});

  final MatchStep step;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final px = (323 * s * MediaQuery.devicePixelRatioOf(context)).ceil();
    return Container(
      padding: EdgeInsets.all(11 * s),
      decoration: _cardBox(s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (step.image != null) ...<Widget>[
            ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14 * s),
                child: AspectRatio(
                  aspectRatio: step.imageAspect,
                  child: Image.asset(
                    step.image!,
                    fit: BoxFit.cover,
                    cacheWidth: px,
                    errorBuilder: (_, error, _) {
                      // Usually: assets/images/tracker/ missing in pubspec.yaml.
                      debugPrint('Tracker step image failed: ${step.image} -> $error');
                      return const ColoredBox(color: Color(0xFF14323A));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.7 * s),
          ],
          Semantics(header: true, child: Text(step.question, style: _q(s))),
          if (step.hint != null)
            Text(
              step.hint!,
              style: _q(s).copyWith(fontSize: 16 * s, color: AppColors.descGrey),
            ),
        ],
      ),
    );
  }
}

OutlineInputBorder _border(double s, Color c, [double w = 1.5]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(17 * s),
      borderSide: BorderSide(color: c, width: w),
    );

/// Text / number answer box.
class AnswerField extends StatelessWidget {
  const AnswerField({
    super.key,
    required this.controller,
    required this.step,
    required this.scale,
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final MatchStep step;
  final double scale;
  final String? errorText;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final number = step.kind == StepKind.number;
    final multi = step.multiline;
    final field = TextField(
      controller: controller,
      expands: multi,
      minLines: multi ? null : 1,
      maxLines: multi ? null : 1,
      textAlignVertical: multi ? TextAlignVertical.top : TextAlignVertical.center,
      keyboardType: number ? TextInputType.number : TextInputType.multiline,
      textInputAction: number ? TextInputAction.next : TextInputAction.newline,
      inputFormatters: number
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)]
          : <TextInputFormatter>[LengthLimitingTextInputFormatter(200)],
      textCapitalization: number ? TextCapitalization.none : TextCapitalization.sentences,
      cursorColor: AppColors.accent,
      onSubmitted: (_) => onSubmitted?.call(),
      style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 18 * s, color: AppColors.white),
      decoration: InputDecoration(
        hintText: step.placeholder,
        hintStyle: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 18 * s, color: AppColors.hint),
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 21 * s, vertical: multi ? 16 * s : 14 * s),
        enabledBorder: _border(s, errorText == null ? AppColors.fieldBorder : AppColors.error),
        focusedBorder: _border(s, errorText == null ? AppColors.accent : AppColors.error),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: (multi ? 85.3 : 55.3) * s, child: field),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.fromLTRB(6 * s, 6 * s, 0, 0),
            child: Text(
              errorText!,
              style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 13 * s, color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// dd/mm/yyyy box that opens the date picker.
class DateAnswerField extends StatelessWidget {
  const DateAnswerField({super.key, required this.value, required this.onTap, required this.scale});

  final DateTime? value;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: 'Match date, ${value == null ? 'not selected' : TrackerFormat.formDate(value!)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(17 * s),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            height: 55.3 * s,
            padding: EdgeInsets.fromLTRB(21 * s, 0, 18 * s, 0),
            decoration: BoxDecoration(
              color: AppColors.fieldFill,
              borderRadius: BorderRadius.circular(17 * s),
              border: Border.all(color: AppColors.accent, width: 1.5),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    value == null ? 'dd/mm/yyyy' : TrackerFormat.formDate(value!),
                    style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 18 * s, color: AppColors.white),
                  ),
                ),
                Icon(Icons.calendar_month_outlined, size: 24 * s, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Last step: dashed "Upload Image" box + caption.
class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key,
    required this.question,
    required this.photoPath,
    required this.onPick,
    required this.onRemove,
    required this.scale,
  });

  final String question;
  final String? photoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final has = photoPath != null;
    return Container(
      padding: EdgeInsets.fromLTRB(25 * s, 25 * s, 25 * s, 30 * s),
      decoration: _cardBox(s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            button: true,
            label: has ? 'Change photo' : 'Upload image. JPG or PNG, up to 20 megabytes',
            child: GestureDetector(
              onTap: onPick,
              child: CustomPaint(
                foregroundPainter: _DashedBorder(radius: 20 * s, color: const Color(0xFF9AA6AA)),
                child: Container(
                  height: 125 * s,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF46585D),
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                  child: has
                      ? Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.file(File(photoPath!), fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox.shrink()),
                            Positioned(
                              top: 4 * s,
                              right: 4 * s,
                              child: IconButton.filled(
                                tooltip: 'Remove photo',
                                onPressed: onRemove,
                                style: IconButton.styleFrom(backgroundColor: const Color(0xAA000000)),
                                icon: const Icon(Icons.close, color: AppColors.white, size: 18),
                              ),
                            ),
                          ],
                        )
                      : ExcludeSemantics(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.photo_camera_outlined, size: 30 * s, color: AppColors.white),
                              SizedBox(height: 6 * s),
                              Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 18 * s,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                'JPG or PNG, up to 20MB',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14 * s,
                                  height: 1.4,
                                  color: const Color(0xFFB0B7BA),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25 * s),
          Semantics(header: true, child: Text(question, style: _q(s).copyWith(height: 1.4))),
        ],
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder old) => old.radius != radius || old.color != color;
}

/// Previous / Next (or Finish) buttons.
class FormButtons extends StatelessWidget {
  const FormButtons({
    super.key,
    required this.showPrevious,
    required this.primaryLabel,
    required this.primaryEnabled,
    required this.primaryLoading,
    required this.onPrevious,
    required this.onPrimary,
    required this.scale,
  });

  final bool showPrevious;
  final String primaryLabel;
  final bool primaryEnabled;
  final bool primaryLoading;
  final VoidCallback onPrevious;
  final VoidCallback onPrimary;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(17 * s);
    TextStyle t(Color c) => TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 18 * s,
          fontWeight: FontWeight.w600,
          color: c,
        );

    Widget button({
      required String label,
      required VoidCallback? onTap,
      required Color fill,
      required Color border,
      required Color text,
      bool loading = false,
    }) =>
        Expanded(
          child: Semantics(
            button: true,
            enabled: onTap != null,
            label: label,
            child: Material(
              color: fill,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: border, width: border == Colors.transparent ? 0 : 1.5),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: SizedBox(
                  height: 43.7 * s,
                  child: Center(
                    child: loading
                        ? SizedBox(
                            width: 20 * s,
                            height: 20 * s,
                            child: CircularProgressIndicator(strokeWidth: 2, color: text),
                          )
                        : ExcludeSemantics(child: Text(label, style: t(text))),
                  ),
                ),
              ),
            ),
          ),
        );

    return Row(
      children: <Widget>[
        if (showPrevious) ...<Widget>[
          button(
            label: 'Previous',
            onTap: primaryLoading ? null : onPrevious,
            fill: Colors.transparent,
            border: AppColors.accent,
            text: AppColors.accent,
          ),
          SizedBox(width: 8 * s),
        ],
        button(
          label: primaryLabel,
          onTap: primaryEnabled && !primaryLoading ? onPrimary : null,
          fill: primaryEnabled ? AppColors.accent : Colors.transparent,
          border: primaryEnabled ? Colors.transparent : const Color(0xFFB0B8BB),
          text: primaryEnabled ? AppColors.black : const Color(0xFF9AA3A6),
          loading: primaryLoading,
        ),
      ],
    );
  }
}

/// "Great Job!" screen.
class SuccessView extends StatelessWidget {
  const SuccessView({super.key, required this.onDone, required this.onAnother, required this.scale});

  final VoidCallback onDone;
  final VoidCallback onAnother;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExcludeSemantics(
          child: Container(
            width: 100 * s,
            height: 100 * s,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2.5 * s),
            ),
            child: Icon(Icons.fact_check_outlined, size: 54 * s, color: const Color(0xFF15323C)),
          ),
        ),
        SizedBox(height: 25 * s),
        Semantics(
          header: true,
          child: Text(
            'Great Job!',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 28 * s,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(height: 17 * s),
        Text(
          'Your performance has been saved. Keep training, keep improving — and '
          'get ready to shine even brighter in your next game! ⚽ 🌟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18 * s,
            height: 1.33,
            color: AppColors.descGrey,
          ),
        ),
        SizedBox(height: 49 * s),
        SizedBox(
          width: double.infinity,
          child: FormButtons(
            showPrevious: false,
            primaryLabel: 'Done',
            primaryEnabled: true,
            primaryLoading: false,
            onPrevious: () {},
            onPrimary: onDone,
            scale: s,
          ),
        ),
        SizedBox(height: 13.7 * s),
        TextButton(
          onPressed: onAnother,
          child: Text(
            'Make Another Submission',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18 * s,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

