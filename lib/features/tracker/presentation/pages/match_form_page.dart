import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';
import 'package:ecoach_pro/features/tracker/presentation/controllers/match_form_controller.dart';
import 'package:ecoach_pro/features/tracker/presentation/widgets/form_widgets.dart';

/// 13-step "Match Rating" form + success screen.
class MatchFormPage extends GetView<MatchFormController> {
  const MatchFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Match Rating',
      navIndex: 4,
      body: Obx(() {
        if (controller.done.value) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.gutter + 24 * s, vertical: 24 * s),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 345 * s),
                child: SuccessView(
                  scale: s,
                  onDone: Get.back,
                  onAnother: controller.startOver,
                ),
              ),
            ),
          );
        }

        final step = controller.current;
        final index = controller.step.value;
        final last = index == MatchFormController.total - 1;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 16 * s),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: KeyedSubtree(
                        key: ValueKey<int>(index),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            StepPill(step: index + 1, total: MatchFormController.total, scale: s),
                            SizedBox(height: 16.3 * s),
                            if (step.kind == StepKind.photo) ...<Widget>[
                              Obx(
                                () => UploadCard(
                                  question: step.question,
                                  photoPath: controller.photoPath.value,
                                  onPick: controller.pickPhoto,
                                  onRemove: controller.removePhoto,
                                  scale: s,
                                ),
                              ),
                              SizedBox(height: 23.7 * s),
                              Text(
                                'If you do not wish to upload a picture, simply click finish.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14 * s,
                                  height: 1.5,
                                  color: AppColors.descGrey,
                                ),
                              ),
                            ] else ...<Widget>[
                              QuestionCard(step: step, scale: s),
                              SizedBox(height: 16.7 * s),
                              if (step.kind == StepKind.date)
                                Obx(
                                  () => DateAnswerField(
                                    value: controller.date.value,
                                    onTap: () => _pickDate(context),
                                    scale: s,
                                  ),
                                )
                              else
                                _Answer(controller: controller, step: step, scale: s),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 4 * s, hPad, 20 * s),
                  child: Obx(
                    () => FormButtons(
                      showPrevious: index > 0,
                      primaryLabel: last ? 'Finish' : 'Next',
                      primaryEnabled: last ? true : controller.canContinue.value,
                      primaryLoading: controller.saving.value,
                      onPrevious: controller.previous,
                      onPrimary: last ? controller.finish : controller.next,
                      scale: s,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.date.value ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.black,
            surface: Color(0xFF0B3542),
            onSurface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.setDate(picked);
  }
}

/// Rebuilds only the error text when the number changes.
class _Answer extends StatelessWidget {
  const _Answer({required this.controller, required this.step, required this.scale});

  final MatchFormController controller;
  final MatchStep step;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final field = controller.fields[step.key]!;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: field,
      builder: (_, _, _) => AnswerField(
        controller: field,
        step: step,
        scale: scale,
        errorText: controller.errorFor(step),
        onSubmitted: controller.next,
      ),
    );
  }
}
