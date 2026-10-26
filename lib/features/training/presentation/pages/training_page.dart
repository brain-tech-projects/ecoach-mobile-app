import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_controller.dart';
import 'package:ecoach_pro/features/training/presentation/widgets/level_progress_card.dart';
import 'package:ecoach_pro/features/training/presentation/widgets/training_tile.dart';

/// "My Training" tab.
class TrainingPage extends GetView<TrainingController> {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'My Training',
      navIndex: MainNav.trainingIndex,
      body: Obx(() {
        final levels = controller.levels;
        if (levels.isEmpty) {
          if (controller.errorMessage.value != null) {
            return _Error(message: controller.errorMessage.value!, onRetry: controller.load, scale: s);
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        final gap = 8.7 * s;
        final rows = <Widget>[];
        for (var i = 0; i < levels.length; i += 2) {
          if (i > 0) rows.add(SizedBox(height: gap));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var j = 0; j < 2; j++) ...<Widget>[
                  if (j > 0) SizedBox(width: gap),
                  Expanded(
                    child: i + j < levels.length
                        ? TrainingTile(
                            level: levels[i + j],
                            scale: s,
                            onTap: () => controller.openLevel(levels[i + j]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            r.gutter + 24 * s,
            25.6 * s,
            r.gutter + 24 * s,
            24 * s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Start your eCoach journey.',
                textAlign: TextAlign.center,
                style: AppTextStyles.trainHeadline.scaled(s),
              ),
              SizedBox(height: 13.2 * s),
              Text(
                'Progress through and see the levels unlock',
                textAlign: TextAlign.center,
                style: AppTextStyles.trainSubline.scaled(s),
              ),
              SizedBox(height: 24.8 * s),
              LevelProgressCard(
                level: levels.first,
                scale: s,
                onTap: () => controller.openLevel(levels.first),
              ),
              SizedBox(height: 24.3 * s),
              ...rows,
            ],
          ),
        );
      }),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry, required this.scale});

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(message, style: AppTextStyles.trainSubline.scaled(scale)),
        TextButton(
          onPressed: onRetry,
          child: Text('Retry', style: AppTextStyles.action.scaled(scale)),
        ),
      ],
    ),
  );
}
