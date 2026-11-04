import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/chat_list_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/chat_widgets.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

/// Chats: "Coach" section with the connected coach.
class ChatListPage extends GetView<ChatListController> {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'Chats',
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        if (controller.errorMessage.value != null) {
          return RetryMessage(
            message: controller.errorMessage.value!,
            onRetry: controller.load,
            scale: s,
          );
        }
        final coach = controller.coach.value;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: ChatFrame(
              scale: s,
              child: SizedBox.expand(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 72 * s,
                      color: kChatHeader,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 24 * s),
                      child: Semantics(
                        header: true,
                        child: Text(
                          'Coach',
                          style: AppTextStyles.sectionHeading.scaled(s).copyWith(
                                fontSize: 20 * s,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: kChatLine),
                    if (coach == null)
                      Padding(
                        padding: EdgeInsets.all(24 * s),
                        child: Text(
                          'You are not connected to a coach yet.',
                          style: AppTextStyles.programDesc.scaled(s),
                        ),
                      )
                    else
                      InkWell(
                        onTap: () => controller.open(coach),
                        child: Semantics(
                          button: true,
                          label: 'Chat with ${coach.name}',
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16 * s, 16.7 * s, 16 * s, 16.7 * s),
                            child: Row(
                              children: <Widget>[
                                CoachAvatar(
                                  asset: coach.avatarAsset,
                                  url: coach.avatarUrl,
                                  size: 48 * s,
                                ),
                                SizedBox(width: 16 * s),
                                Expanded(
                                  child: ExcludeSemantics(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          coach.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: AppTextStyles.fontFamily,
                                            fontSize: 18 * s,
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        Text(
                                          'Tap to chat',
                                          style: TextStyle(
                                            fontFamily: AppTextStyles.fontFamily,
                                            fontSize: 16 * s,
                                            height: 1.3,
                                            color: kChatMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
