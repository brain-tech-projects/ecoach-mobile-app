import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/coach/presentation/controllers/coach_training_detail_controller.dart';

/// One coach-assigned training: video + "Video Complete".
class CoachTrainingDetailPage extends GetView<CoachTrainingDetailController> {
  const CoachTrainingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final training = controller.training;

    return SubPageScaffold(
      title: training.title,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(r.gutter + 24 * s, 28 * s, r.gutter + 24 * s, 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppVideoPlayer(
              key: ValueKey<String>(training.id),
              url: training.videoUrl,
              height: 240,
              scale: s,
            ),
            SizedBox(height: 15.5 * s),
            Text(training.title, style: AppTextStyles.sectionHeading.scaled(s)),
            SizedBox(height: 32.7 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 49 * s),
              child: Obx(
                () => AppPrimaryButton(
                  label: 'Video Complete',
                  loading: controller.completing.value,
                  onPressed: controller.onVideoComplete,
                  scale: s,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
