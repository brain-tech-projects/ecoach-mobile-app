import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skill_detail_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/drill_menu.dart';

/// One drill: video (with the "⋮" menu), description, focus, equipment and
/// "Video Complete".
class SkillDetailPage extends GetView<SkillDetailController> {
  const SkillDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: controller.drill.value.title,
      body: Obx(() {
        final drill = controller.drill.value;

        if (drill.videoUrl.isEmpty) {
          if (controller.errorMessage.value != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.trainSubline.scaled(s),
                  ),
                  TextButton(
                    onPressed: controller.load,
                    child: Text('Retry', style: AppTextStyles.action.scaled(s)),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            r.gutter + 24 * s,
            36.6 * s,
            r.gutter + 24 * s,
            24 * s,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AppVideoPlayer(
                    key: ValueKey<int>(drill.id),
                    url: drill.videoUrl,
                    height: 231.7,
                    scale: s,
                  ),
                  Positioned(
                    top: 6 * s,
                    right: 6 * s,
                    child: Builder(
                      builder: (anchor) => Semantics(
                        button: true,
                        label: 'More options',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => showDrillMenu(
                            anchor,
                            scale: s,
                            sessionAdded: !drill.canAddToSession,
                            onAddToSession: controller.toggleSession,
                            onAddNote: controller.addNote,
                          ),
                          child: SizedBox(
                            width: 28 * s,
                            height: 28 * s,
                            child: Icon(
                              Icons.more_vert,
                              size: 24 * s,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.5 * s),
              Text(drill.title, style: AppTextStyles.sectionHeading.scaled(s)),
              if (drill.description.isNotEmpty) ...<Widget>[
                SizedBox(height: 8.2 * s),
                Text(drill.description, style: AppTextStyles.detailDesc.scaled(s)),
              ],
              if (drill.focus.isNotEmpty) ...<Widget>[
                SizedBox(height: 29.6 * s),
                Text.rich(
                  TextSpan(
                    text: 'Focus:',
                    style: AppTextStyles.infoLabel.scaled(s),
                    children: <InlineSpan>[
                      TextSpan(
                        text: '  ${drill.focus}',
                        style: AppTextStyles.infoValue.scaled(s),
                      ),
                    ],
                  ),
                ),
              ],
              if (drill.equipment.isNotEmpty) ...<Widget>[
                SizedBox(height: 14 * s),
                Container(
                  constraints: BoxConstraints(minHeight: 68.3 * s),
                  padding: EdgeInsets.fromLTRB(17.3 * s, 14 * s, 17.3 * s, 14 * s),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(10.5 * s),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Equipment:',
                      style: AppTextStyles.infoLabel.scaled(s),
                      children: <InlineSpan>[
                        TextSpan(
                          text: '  ${drill.equipment}',
                          style: AppTextStyles.infoValue.scaled(s),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24.3 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 49 * s),
                child: AppPrimaryButton(
                  label: drill.completed ? 'Completed' : 'Video Complete',
                  enabled: !drill.completed,
                  loading: controller.isSubmitting.value,
                  onPressed: controller.onVideoComplete,
                  scale: s,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
