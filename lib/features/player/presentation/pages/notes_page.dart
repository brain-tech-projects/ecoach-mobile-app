import 'package:ecoach_pro/core/widgets/empty_state_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/notes_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/note_node_card.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

/// Notes: Skills Notes | Challenges Notes.
class NotesPage extends GetView<NotesController> {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Notes',
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
        final nodes = tab == 0 ? controller.skillNotes : controller.challengeNotes;
        final open = Set<String>.of(controller.expanded); // subscribes to changes

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 34 * s, hPad, 0),
              child: UnderlineTabs(
                labels: const <String>['Skills Notes', 'Challenges Notes'],
                selected: tab,
                onChanged: (i) => controller.tab.value = i,
                scale: s,
              ),
            ),
            Expanded(
              child: nodes.isEmpty
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
                  title: 'No notes added yet',
                  subtitle: 'Save skills to your personal list so you can practice anytime and track your progress.',
                  actionLabel: 'Add Skills Notes',
                  onAction: controller.addSkillsnote,
                  scale: s,
                )
              else
                EmptyStateCard(
                  title: 'No notes added yet',
                  subtitle: 'Add challenges to stay motivated, compete with others, and improve your performance.',
                  actionLabel: 'Add Challenges Notes',
                  onAction: controller.exploreChallengesnote,
                  scale: s,
                ),
            ],
          ),
        )
                  : RefreshIndicator(
                      onRefresh: controller.load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(hPad, 25.7 * s, hPad, 24 * s),
                        itemCount: nodes.length,
                        separatorBuilder: (_, _) => SizedBox(height: 16.3 * s),
                        itemBuilder: (context, i) => NoteNodeCard(
                          node: nodes[i],
                          scale: s,
                          isExpanded: open.contains,
                          onToggle: controller.toggle,
                          onDeleteNote: controller.deleteNote,
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
