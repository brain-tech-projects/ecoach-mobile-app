import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/tour/presentation/controllers/tour_controller.dart';

/// Signed-out "Take The Tour": intro text, video player, description and a
/// thumbnail strip to switch videos.
class TourPage extends GetView<TourController> {
  const TourPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Take The Tour',
      body: Obx(() {
        final video = controller.selected;
        if (video == null) {
          if (controller.loading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  controller.errorMessage.value ?? 'No tour videos yet.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.trainSubline.scaled(s),
                ),
                if (controller.errorMessage.value != null)
                  TextButton(
                    onPressed: controller.load,
                    child: Text('Retry', style: AppTextStyles.action.scaled(s)),
                  ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 27 * s, hPad, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                TourController.intro,
                textAlign: TextAlign.center,
                style: AppTextStyles.trainSubline.scaled(s),
              ),
              SizedBox(height: 28 * s),
              Padding(
                padding: EdgeInsets.only(left: 12 * s),
                child: Text(
                  video.title,
                  style: AppTextStyles.sectionHeading.scaled(s),
                ),
              ),
              SizedBox(height: 12 * s),
              AppVideoPlayer(
                key: ValueKey<int>(video.id),
                url: video.videoUrl,
                height: 231.7,
                scale: s,
              ),
              SizedBox(height: 14 * s),
              Text(video.title, style: AppTextStyles.sectionHeading.scaled(s)),
              SizedBox(height: 8 * s),
              Text(video.description, style: AppTextStyles.detailDesc.scaled(s)),
              SizedBox(height: 20 * s),
              Wrap(
                spacing: 14 * s,
                runSpacing: 14 * s,
                children: <Widget>[
                  for (var i = 0; i < controller.videos.length; i++)
                    _Thumb(
                      imageUrl: controller.videos[i].posterUrl,
                      label: controller.videos[i].title,
                      selected: i == controller.selectedIndex.value,
                      scale: s,
                      onTap: () => controller.select(i),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.imageUrl,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String? imageUrl;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 90 * s,
          height: 90 * s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: selected ? AppColors.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl == null
              ? const ColoredBox(color: AppColors.card)
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: AppColors.card),
                ),
        ),
      ),
    );
  }
}
