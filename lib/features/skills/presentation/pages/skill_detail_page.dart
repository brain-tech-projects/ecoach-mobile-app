import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/core/widgets/video/video_info_section.dart';
import 'package:ecoach_pro/features/skills/presentation/controllers/skill_detail_controller.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/drill_menu.dart';

/// One drill: video (with the "⋮" menu), description, top tip, bullet box
/// and "Video Complete" - all content comes from the API.
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
              VideoInfoSection(
                title: drill.title,
                description: drill.description,
                topTip: drill.topTip,
                points: drill.instructions,
                scale: s,
              ),
              SizedBox(height: 24.3 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * s),
                child: AppPrimaryButton(
                  label: 'Video Complete',
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
