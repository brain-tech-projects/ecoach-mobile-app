import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_detail_controller.dart';
import 'package:ecoach_pro/features/training/presentation/widgets/training_video_thumb.dart';

/// One training level: player (or locked preview) + row of numbered videos.
class TrainingDetailPage extends GetView<TrainingDetailController> {
  const TrainingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: controller.level.title,
      navIndex: MainNav.trainingIndex,
      body: Obx(() {
        final videos = controller.videos.toList();
        final index = controller.currentIndex.value;
        final video = videos.isEmpty ? null : videos[index];

        if (video == null) {
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
          if (!controller.isLoading.value) {
            return Center(
              child: Text(
                'No videos yet.',
                style: AppTextStyles.trainSubline.scaled(s),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(top: 28.3 * s, bottom: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: video.locked
                    ? _LockedPreview(imageUrl: video.imageUrl, scale: s)
                    : AppVideoPlayer(
                        key: ValueKey<int>(video.id),
                        url: video.videoUrl,
                        height: 240,
                        scale: s,
                        autoPlay: true,
                        onEnded: controller.onVideoEnded,
                      ),
              ),
              SizedBox(height: 7.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text(
                  video.title,
                  style: AppTextStyles.sectionHeading.scaled(s),
                ),
              ),
              SizedBox(height: 16.5 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: SizedBox(
                  height: 81.7 * s,
                  child: ClipRect(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 9 * s),
                      itemCount: videos.length,
                      separatorBuilder: (_, _) => SizedBox(width: 10 * s),
                      itemBuilder: (context, i) => TrainingVideoThumb(
                        locked: videos[i].locked,
                        selected: i == index,
                        label: videos[i].title,
                        imageUrl: videos[i].imageUrl,
                        scale: s,
                        onTap: () => controller.select(i),
                      ),
                    ),
                  ),
                ),
              ),
              if (video.locked) ...<Widget>[
                SizedBox(height: 32 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: AppPrimaryButton(
                    label: _lockedLabel(video),
                    onPressed: () {},
                    scale: s,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  /// "Next available in 2 Days" from `available_after_days`.
  static String _lockedLabel(TrainingVideo video) {
    final days = video.availableAfterDays;
    if (days == null || days <= 0) {
      return 'Complete the previous video to unlock';
    }
    return 'Next available in $days ${days == 1 ? 'Day' : 'Days'}';
  }
}

/// Dimmed poster with a padlock, shown instead of the player.
class _LockedPreview extends StatelessWidget {
  const _LockedPreview({required this.scale, this.imageUrl});

  final double scale;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final fallback = Image.asset(AppAssets.thumbLocked, fit: BoxFit.cover);

    return Container(
      height: 240 * s,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (imageUrl == null)
            fallback
          else
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
          const ColoredBox(color: Color(0x8C000000)),
          Center(
            child: Icon(Icons.lock, size: 44 * s, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}