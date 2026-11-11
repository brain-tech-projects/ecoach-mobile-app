import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/personal_training/presentation/controllers/personal_training_player_controller.dart';
import 'package:ecoach_pro/features/personal_training/presentation/widgets/next_video_popup.dart';

/// Plays the personal session: video, Previous / Next, details and the
/// auto-advance countdown popup.
class PersonalTrainingPlayerPage
    extends GetView<PersonalTrainingPlayerController> {
  const PersonalTrainingPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return Obx(() {
      final drill = controller.current;
      final hasPrev = controller.hasPrevious;
      final hasNext = controller.hasNext;
      final seconds = controller.countdown.value;

      return SubPageScaffold(
        title: drill.title,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: drill.videoUrl.isEmpty
                  ? _Loading(controller: controller, scale: s)
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 36.6 * s, hPad, 24 * s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppVideoPlayer(
                            key: ValueKey<int>(drill.id),
                            url: drill.videoUrl,
                            height: 231.7,
                            scale: s,
                            autoPlay: true,
                            onEnded: controller.onVideoEnded,
                          ),
                          SizedBox(height: 18 * s),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6 * s),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _NavLink(
                                  label: 'Previous',
                                  enabled: hasPrev,
                                  scale: s,
                                  onTap: controller.previous,
                                ),
                                _NavLink(
                                  label: 'Next',
                                  enabled: hasNext,
                                  scale: s,
                                  onTap: controller.next,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18 * s),
                          Text(
                            drill.title,
                            style: AppTextStyles.sectionHeading.scaled(s),
                          ),
                          if (drill.description.isNotEmpty) ...<Widget>[
                            SizedBox(height: 8.2 * s),
                            Text(
                              drill.description,
                              style: AppTextStyles.detailDesc.scaled(s),
                            ),
                          ],
                          if (drill.focus.isNotEmpty) ...<Widget>[
                            SizedBox(height: 24 * s),
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
                              padding: EdgeInsets.fromLTRB(
                                17.3 * s,
                                14 * s,
                                17.3 * s,
                                14 * s,
                              ),
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
                        ],
                      ),
                    ),
            ),
            if (seconds != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16 * s,
                child: Center(
                  child: NextVideoPopup(
                    seconds: seconds,
                    onCancel: controller.cancelCountdown,
                    scale: s,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.controller, required this.scale});

  final PersonalTrainingPlayerController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final error = controller.errorMessage.value;
    if (error == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTextStyles.trainSubline.scaled(scale),
          ),
          TextButton(
            onPressed: controller.loadDetails,
            child: Text('Retry', style: AppTextStyles.action.scaled(scale)),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$label video',
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 8 * scale),
          child: Opacity(
            opacity: enabled ? 1 : 0.35,
            child: Text(
              label,
              style: AppTextStyles.programTitle.scaled(scale * 1.15),
            ),
          ),
        ),
      ),
    );
  }
}
