import 'package:ecoach_pro/core/widgets/empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/my_skills_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

/// My Skills: All Skills | Challenges.
class MySkillsPage extends GetView<MySkillsController> {
  const MySkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'My Skills',
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        if (controller.errorMessage.value != null) {
          return RetryMessage(
            message: controller.errorMessage.value!,
            onRetry: controller.load,
            scale: s,
          );
        }
        final tab = controller.tab.value;
        final empty = tab == 0 ? controller.skills.isEmpty : controller.challenges.isEmpty;

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 34 * s, hPad, 0),
              child: UnderlineTabs(
                labels: const <String>['All Skills', 'Challenges'],
                selected: tab,
                onChanged: (i) => controller.tab.value = i,
                scale: s,
              ),
            ),
            Expanded(
  child: empty
      ? RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
            children: <Widget>[
              if (tab == 0)
                EmptyStateCard(
                  title: 'No skills added yet',
                  subtitle: 'Start building your personal training library.',
                  actionLabel: 'Add Skills',
                  onAction: controller.addSkills,
                  scale: s,
                )
              else
                EmptyStateCard(
                  title: 'No challenges found',
                  subtitle: 'Join challenges to test your abilities.',
                  actionLabel: 'Explore Challenges',
                  onAction: controller.exploreChallenges,
                  scale: s,
                ),
            ],
          ),
        )
      : RefreshIndicator(
          // ...your existing list code, unchanged
                      onRefresh: controller.load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(hPad, 25.7 * s, hPad, 24 * s),
                        itemCount: tab == 0
                            ? controller.skills.length
                            : controller.challenges.length,
                        separatorBuilder: (_, _) => SizedBox(height: 0.7 * s),
                        itemBuilder: (context, i) {
                          if (tab == 0) {
                            final sk = controller.skills[i];
                            return SavedItemCard(
                              title: sk.drill.title,
                              thumbnail: sk.drill.thumbnail,
                              scale: s,
                              onTap: () => controller.openSkill(sk),
                              onRemove: () => controller.removeSkill(sk),
                            );
                          }
                          final c = controller.challenges[i];
                          return SavedItemCard(
                            title: c.title,
                            thumbnail: c.thumbnail,
                            scale: s,
                            onTap: () => controller.openChallenge(c),
                            onRemove: () => controller.removeChallenge(c),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
