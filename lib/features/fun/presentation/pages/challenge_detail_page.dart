import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenge_detail_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// One challenge: video + title.
class ChallengeDetailPage extends GetView<ChallengeDetailController> {
  const ChallengeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    return SubPageScaffold(
      title: controller.challenge.value.title,
      navIndex: MainNav.funIndex,
      body: Obx(() {
        final c = controller.challenge.value;
        final error = controller.errorMessage.value;
        if (error != null) {
          return FunErrorView(message: error, onRetry: controller.load, scale: s);
        }
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(r.gutter + 24 * s, 51.3 * s, r.gutter + 24 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppVideoPlayer(
                // New key when the details bring a fresh video URL.
                key: ValueKey<String>('${c.id}|${c.videoUrl}'),
                url: c.videoUrl,
                height: 217,
                scale: s,
                posterAsset: c.thumbnail.startsWith('http') ? null : c.thumbnail,
              ),
              SizedBox(height: 15.5 * s),
              Text(c.title, style: AppTextStyles.sectionHeading.scaled(s)),
            ],
          ),
        );
      }),
    );
  }
}
