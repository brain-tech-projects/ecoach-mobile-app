import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skills_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/skill_tile.dart';

/// "Skills" tab: pick a skill area.
class SkillsPage extends GetView<SkillsController> {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'Skills',
      navIndex: MainNav.skillsIndex,
      body: Obx(() {
        final categories = controller.categories;
        if (categories.isEmpty) {
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

        final gap = 8.7 * s;
        final rows = <Widget>[];
        for (var i = 0; i < categories.length; i += 2) {
          if (i > 0) rows.add(SizedBox(height: 8.3 * s));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var j = 0; j < 2; j++) ...<Widget>[
                  if (j > 0) SizedBox(width: gap),
                  Expanded(
                    child: i + j < categories.length
                        ? SkillTile(
                            category: categories[i + j],
                            scale: s,
                            onTap: () => controller.openCategory(categories[i + j]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(r.gutter + 24 * s, 27.8 * s, r.gutter + 24 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Select a skill area to focus on',
                textAlign: TextAlign.center,
                style: AppTextStyles.trainSubline.scaled(s),
              ),
              SizedBox(height: 24.5 * s),
              ...rows,
            ],
          ),
        );
      }),
    );
  }
}
