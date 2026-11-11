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
  return RefreshIndicator(
    onRefresh: controller.load,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 27.8 * s, hPad, 24 * s),
      children: <Widget>[
        intro('Connect to a team or coach to see allocated training sessions.'),
        SizedBox(height: 16 * s),
        Center(
          child: _AddCoachButton(scale: s, onTap: controller.openInvite),
        ),
      ],
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

class _AddCoachButton extends StatelessWidget {
  const _AddCoachButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 52 * s,
          height: 52 * s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF2FD36B), Color(0xFF148A3C)],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                blurRadius: 12 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.black, size: 28 * s),
        ),
      ),
    );
  }
}
