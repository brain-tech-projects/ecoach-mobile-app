import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_background.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/domain/entities/programme_summary.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/programme_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/programme_ring.dart';

/// "Generating your personalised programme" -> "Your programme is ready".
class ProgrammePage extends GetView<ProgrammeController> {
  const ProgrammePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final top = math.max(r.safeTop, r.s(20));
    final bottom = math.max(r.safeBottom, r.s(24));

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: top, bottom: bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.s(22)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 32.7 * s),
                      Center(child: AppLogoHorizontal(scale: s)),
                      SizedBox(height: 40 * s),
                      Obx(
                        () => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: controller.phase.value ==
                                  ProgrammePhase.generating
                              ? _Generating(
                                  key: const ValueKey<String>('gen'),
                                  controller: controller,
                                  scale: s,
                                )
                              : _Ready(
                                  key: const ValueKey<String>('ready'),
                                  controller: controller,
                                  scale: s,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Generating extends StatelessWidget {
  const _Generating({super.key, required this.controller, required this.scale});

  final ProgrammeController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            'Generating your personalised programme',
            textAlign: TextAlign.center,
            style: AppTextStyles.authTitle.scaled(s),
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          'This will only take a few seconds...',
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubtitle.scaled(s * 0.85),
        ),
        SizedBox(height: 30 * s),
        Center(child: ProgrammeRing(size: 190 * s)),
        SizedBox(height: 30 * s),
        Obx(() {
          final done = controller.completedSteps.value;
          return Column(
            children: <Widget>[
              for (var i = 0; i < ProgrammeController.stepLabels.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 10 * s),
                  child: _StepRow(
                    label: ProgrammeController.stepLabels[i],
                    state: i < done
                        ? _StepState.done
                        : (i == done ? _StepState.active : _StepState.idle),
                    scale: s,
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

enum _StepState { idle, active, done }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.state,
    required this.scale,
  });

  final String label;
  final _StepState state;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final done = state == _StepState.done;
    final box = 20 * s;

    return Semantics(
      label: done ? '$label, done' : label,
      excludeSemantics: true,
      child: Container(
        height: 44 * s,
        padding: EdgeInsets.symmetric(horizontal: 14 * s),
        decoration: BoxDecoration(
          color: AppColors.countryFill.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8 * s),
          border: Border.all(color: AppColors.countryBorder),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: box,
              height: box,
              child: done
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4 * s),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 15 * s,
                        color: AppColors.checkMark,
                      ),
                    )
                  : state == _StepState.active
                  ? Padding(
                      padding: EdgeInsets.all(2 * s),
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: AppColors.accent,
                      ),
                    )
                  : Icon(
                      Icons.circle_outlined,
                      size: box - 2,
                      color: AppColors.checkIdle,
                    ),
            ),
            SizedBox(width: 12 * s),
            Expanded(
              child: Text(
                done ? label : '$label…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.noteText.scaled(s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({super.key, required this.controller, required this.scale});

  final ProgrammeController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final summary = controller.args.summary;
    final rows = <_SummaryRowData>[
      _SummaryRowData(Icons.person_outline, 'Age', summary.age),
      _SummaryRowData(Icons.shield_outlined, 'Positions', summary.positions),
      _SummaryRowData(Icons.emoji_events_outlined, 'Level', summary.level),
      _SummaryRowData(Icons.star_border, 'Focus', summary.focus),
      _SummaryRowData(Icons.flag_outlined, 'Goals', summary.goals),
      _SummaryRowData(
        Icons.calendar_today_outlined,
        'Training frequency',
        summary.frequency,
      ),
    ].where((e) => e.value.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            'Your personalised programme is ready! 🎉',
            textAlign: TextAlign.center,
            style: AppTextStyles.authTitle.scaled(s),
          ),
        ),
        SizedBox(height: 4 * s),
        Text(
          'Here\'s what we\'ve created for your player.',
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubtitle.scaled(s * 0.85),
        ),
        SizedBox(height: 18 * s),
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * s),
          child: AspectRatio(
            aspectRatio: 497 / 750,
            child: Image.asset(
              AppAssets.programmeHero,
              fit: BoxFit.fill,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.countryFill),
            ),
          ),
        ),
        SizedBox(height: 14 * s),
        Container(
          padding: EdgeInsets.fromLTRB(16 * s, 14 * s, 16 * s, 4 * s),
          decoration: BoxDecoration(
            color: AppColors.countryFill.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10 * s),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: <Widget>[
              for (final row in rows) _SummaryRow(data: row, scale: s),
            ],
          ),
        ),
        SizedBox(height: 22 * s),
        Obx(
          () => AppPrimaryButton(
            label: controller.unlocking.value
                ? 'Unlocking...'
                : 'Unlock My Programme',
            loading: controller.unlocking.value,
            onPressed: controller.unlock,
            scale: s,
          ),
        ),
      ],
    );
  }
}

class _SummaryRowData {
  const _SummaryRowData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data, required this.scale});

  final _SummaryRowData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(data.icon, size: 20 * s, color: AppColors.accent),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.label,
                  style: AppTextStyles.noteText
                      .scaled(s * 0.9)
                      .copyWith(color: AppColors.accent),
                ),
                SizedBox(height: 1 * s),
                Text(data.value, style: AppTextStyles.noteText.scaled(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
