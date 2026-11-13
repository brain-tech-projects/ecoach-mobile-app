import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/invitations_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

class InvitationsPage extends GetView<InvitationsController> {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    const red = Color(0xFFD64550);

    return SubPageScaffold(
      title: 'Player Invitation',
      navIndex: -1,
      floatingAction: CoachFab(onTap: controller.invite, label: 'Invite player'),
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        final players = controller.players.toList();
        final invites = controller.invitations.toList();
        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 90 * s),
            children: <Widget>[
              Text('Players currently on your team. You can disconnect a player at any time.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400)),
              SizedBox(height: 18 * s),
              for (final p in players)
                Padding(
                  padding: EdgeInsets.only(bottom: 12 * s),
                  child: CoachCard(
                    padding: EdgeInsets.all(11 * s),
                    child: Row(
                      children: <Widget>[
                        CoachPlayerAvatar(url: p.photoUrl, size: 54 * s),
                        SizedBox(width: 14 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w600)),
                              if (p.subtitle.isNotEmpty) Text(p.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programDesc.scaled(s)),
                            ],
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        GestureDetector(
                          onTap: () => controller.disconnect(p),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6 * s), border: Border.all(color: red)),
                            child: Text('Disconnect', style: AppTextStyles.programTitle.scaled(s).copyWith(color: red, fontSize: 16 * s, fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20 * s),
              if (invites.isEmpty) ...<Widget>[
                Text('No invitations found.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 22 * s, fontWeight: FontWeight.w600)),
                SizedBox(height: 8 * s),
                Text('When a player invites you to be their coach, their request will appear here for you to accept or reject.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w400, height: 1.5)),
              ] else
                for (final i in invites) _InviteCard(invitation: i, controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.invitation, required this.controller});
  final PlayerInvitation invitation;
  final InvitationsController controller;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * s),
      child: CoachCard(
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[CoachPlayerAvatar(url: invitation.player.photoUrl, size: 48 * s), SizedBox(width: 12 * s), Expanded(child: Text(invitation.player.name, style: AppTextStyles.programTitle.scaled(s).copyWith(fontWeight: FontWeight.w600)))]),
            SizedBox(height: 12 * s),
            CoachButtonRow(children: <Widget>[
              CoachButton(label: 'Reject', kind: CoachButtonKind.outline, onTap: () => controller.respond(invitation, accept: false)),
              CoachButton(label: 'Accept', onTap: () => controller.respond(invitation, accept: true)),
            ]),
          ],
        ),
      ),
    );
  }
}
