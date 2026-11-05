import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_invitation_controller.dart';
import 'package:ecoach_pro/features/coach/presentation/widgets/coach_card.dart';

/// Coach Invitation: shows the connected coach (or that nothing is pending).
class CoachInvitationPage extends GetView<CoachInvitationController> {
  const CoachInvitationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Coach Invitation',
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();

        final error = controller.errorMessage.value;
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

        final coach = controller.coach.value;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 27.8 * s, hPad, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                coach != null
                    ? "You're connected to a coach. Any new invitations will "
                        'appear here.'
                    : 'You are not currently connected to a coach. Please '
                        'enter your coaches email address to invite them to '
                        'join eCoachPro.',
                textAlign: TextAlign.center,
                style: AppTextStyles.trainSubline.scaled(s),
              ),
              if (coach == null) ...<Widget>[
                SizedBox(height: 14 * s),
                Center(
                  child: Semantics(
                    button: true,
                    label: 'Invite a coach',
                    child: GestureDetector(
                      onTap: controller.openInvite,
                      child: Container(
                        width: 41 * s,
                        height: 41 * s,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              AppColors.selectGreen,
                              Color(0xFF16813B),
                            ],
                          ),
                        ),
                        child: Icon(Icons.add, size: 26 * s, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ],
              if (coach != null) ...<Widget>[
                SizedBox(height: 16.7 * s),
                CoachCard(
                  coach: coach,
                  scale: s,
                  busy: controller.disconnecting.value,
                  onDisconnect: controller.onDisconnect,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
