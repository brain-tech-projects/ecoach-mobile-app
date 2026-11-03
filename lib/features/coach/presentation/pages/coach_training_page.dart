import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_training_controller.dart';
import 'package:ecoach_pro/features/coach/presentation/widgets/training_row.dart';

/// Coaches Training: the skills your coach has set.
class CoachTrainingPage extends GetView<CoachTrainingController> {
  const CoachTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Coaches Training',
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();

        final error = controller.errorMessage.value;
        final items = controller.trainings;

        Widget intro(String text) => Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.trainSubline.scaled(s),
            );

        if (error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(error, style: AppTextStyles.programDesc.scaled(s)),
                TextButton(
                  onPressed: controller.load,
                  child: Text('Retry', style: AppTextStyles.action.scaled(s)),
                ),
              ],
            ),
          );
        }

        if (items.isEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(hPad, 27.8 * s, hPad, 0),
            child: Align(
              alignment: Alignment.topCenter,
              child: intro('Your coach has not set any skills for you yet.'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 27.8 * s, hPad, 24.7 * s),
                sliver: SliverToBoxAdapter(
                  child: intro('Below are the skills you have been set by your coach.'),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24 * s),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 16.7 * s),
                  itemBuilder: (context, i) => TrainingRow(
                    title: items[i].title,
                    scale: s,
                    onTap: () => controller.open(items[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
