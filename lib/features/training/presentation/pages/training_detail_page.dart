import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_detail_controller.dart';
import 'package:ecoach_pro/features/training/presentation/widgets/training_video_thumb.dart';

/// One training level: video player + row of numbered (locked) videos.
class TrainingDetailPage extends GetView<TrainingDetailController> {
  const TrainingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: controller.level.title,
      navIndex: MainNav.trainingIndex,
      body: Obx(() {
        final video = controller.videos.isEmpty
            ? null
            : controller.videos[controller.currentIndex.value];

        if (video == null) {
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

        final unlocked = controller.unlocked.value; // keeps the Obx reactive

        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 28.3 * s, bottom: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.gutter + 24 * s),
                child: AppVideoPlayer(
                  key: ValueKey<String>(video.id),
                  url: video.videoUrl,
                  height: 240,
                  scale: s,
                  autoPlay: true,
                  onEnded: controller.onVideoEnded,
                ),
              ),
              SizedBox(height: 7.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.gutter + 24 * s),
                child: Text(video.title, style: AppTextStyles.sectionHeading.scaled(s)),
              ),
              SizedBox(height: 16.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.gutter + 24 * s),
                child: SizedBox(
                  height: 81.7 * s,
                  child: ClipRect(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 9 * s),
                      itemCount: controller.videos.length,
                      separatorBuilder: (_, _) => SizedBox(width: 10 * s),
                      itemBuilder: (context, i) => TrainingVideoThumb(
                        locked: i >= unlocked,
                        label: controller.videos[i].title,
                        scale: s,
                        onTap: () => controller.select(i),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
