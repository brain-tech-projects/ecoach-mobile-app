import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skill_list_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/drill_card.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/drill_menu.dart';

/// Drills of one skill area (lazy list, smooth scrolling).
class SkillListPage extends GetView<SkillListController> {
  const SkillListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: controller.category.name,
      body: Obx(() {
        final drills = controller.drills;
        if (drills.isEmpty) {
          if (controller.errorMessage.value != null) {
            return Center(
              child: TextButton(
                onPressed: controller.load,
                child: Text('Retry', style: AppTextStyles.action.scaled(s)),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 27.8 * s, hPad, 25.2 * s),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Get ready to ${controller.category.name} like a pro. '
                  'Choose a drill to get started.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.trainSubline.scaled(s),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24 * s),
              sliver: SliverList.separated(
                itemCount: drills.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.9 * s),
                itemBuilder: (context, i) {
                  final drill = drills[i];
                  return DrillCard(
                    drill: drill,
                    scale: s,
                    onTap: () => controller.openDrill(drill),
                    onMenu: (anchor) => showDrillMenu(
                      anchor,
                      scale: s,
                      onAddToSession: () => controller.addToPersonalSession(drill),
                      onAddToMySkills: () => controller.addToMySkills(drill),
                      onAddNote: () => controller.addNote(drill),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
