import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/teams_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

class TeamsPage extends GetView<TeamsController> {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'My Teams',
      navIndex: 0,
      floatingAction: CoachFab(onTap: controller.openAdd, label: 'Add team'),
      body: Obx(() {
        if (controller.loading.value && controller.teams.isEmpty) return const AppLoader();
        final error = controller.errorMessage.value;
        if (error != null && controller.teams.isEmpty) return Center(child: CoachEmpty(text: error, onRetry: controller.load));
        final teams = controller.teams.toList();
        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: controller.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 90 * s),
            itemCount: teams.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 14 * s),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6 * s),
                  child: Text('Create a team and add players to get started.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400)),
                );
              }
              final team = teams[i - 1];
              return _TeamCard(
                team: team,
                onNewGroup: () => controller.newGroup(team),
                onAddPlayers: () => controller.addPlayers(team),
                onEdit: () => controller.openEdit(team),
                onRemove: () => controller.removeTeam(team),
                onRemoveGroup: (g) => controller.removeGroup(team, g),
              );
            },
          ),
        );
      }),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team, required this.onNewGroup, required this.onAddPlayers, required this.onEdit, required this.onRemove, required this.onRemoveGroup});

  final CoachTeam team;
  final VoidCallback onNewGroup;
  final VoidCallback onAddPlayers;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final ValueChanged<TeamGroup> onRemoveGroup;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final placeholder = Icon(Icons.photo_library_outlined, size: 42 * s, color: AppColors.white);

    return CoachCard(
      padding: EdgeInsets.all(12 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 76 * s,
            height: 76 * s,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: const Color(0xFFCCCCCC), borderRadius: BorderRadius.circular(12 * s)),
            child: (team.imageUrl == null) ? placeholder : coachImage(team.imageUrl!, placeholder),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(team.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w600))),
                    SizedBox(
                      width: 28 * s,
                      height: 28 * s,
                      child: CoachKebab(entries: <CoachMenuEntry>[
                        CoachMenuEntry('Add Players', Icons.person_add_alt_1_outlined, onAddPlayers),
                        CoachMenuEntry('Edit', Icons.edit_outlined, onEdit),
                        CoachMenuEntry('Remove', Icons.delete_outline, onRemove),
                      ]),
                    ),
                  ],
                ),
                if (team.description.isNotEmpty) Text(team.description, style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 15 * s)),
                SizedBox(height: 8 * s),
                Wrap(
                  spacing: 8 * s,
                  runSpacing: 8 * s,
                  children: <Widget>[
                    CoachPill(label: 'New group', icon: Icons.people_outline, accent: true, onTap: onNewGroup),
                    for (final g in team.groups) CoachPill(label: g.name, icon: Icons.people_outline, badge: g.playerCount, onRemove: () => onRemoveGroup(g)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
