import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/chat_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/chat_widgets.dart';

/// Conversation with the coach.
class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final coach = controller.coach;

    return SubPageScaffold(
      title: 'Chats',
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
          child: ChatFrame(
            scale: s,
            innerTopGap: 0,
            child: Column(
              children: <Widget>[
                // ---- header ----
                Container(
                  height: 65.7 * s,
                  color: kChatHeader,
                  padding: EdgeInsets.only(left: 10 * s, right: 16 * s),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Back',
                        onPressed: Get.back,
                        icon: Icon(Icons.arrow_back, size: 20 * s, color: AppColors.white),
                      ),
                      SizedBox(width: 8 * s),
                      CoachAvatar(asset: coach.avatarAsset, url: coach.avatarUrl, size: 40 * s),
                      SizedBox(width: 16 * s),
                      Expanded(
                        child: Text(
                          coach.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: kChatLine),
                // ---- messages ----
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    final list = controller.messages;
                    if (list.isEmpty) {
                      return Center(
                        child: Text('Say hi to your coach!', style: AppTextStyles.programDesc.scaled(s)),
                      );
                    }
                    return ListView.separated(
                      controller: controller.scroll,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16 * s, 6.7 * s, 16 * s, 26.7 * s),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.5 * s),
                      itemBuilder: (_, i) => ChatBubble(message: list[i], scale: s),
                    );
                  }),
                ),
                // ---- composer ----
                const Divider(height: 1, thickness: 1, color: kChatLine),
                Padding(
                  padding: EdgeInsets.fromLTRB(16 * s, 17 * s, 16 * s, 16 * s),
                  child: SizedBox(
                    height: 55 * s,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F505B),
                              border: Border.all(color: const Color(0xFF5A727B), width: 1.5),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(17 * s)),
                            ),
                            child: TextField(
                              controller: controller.input,
                              minLines: 1,
                              maxLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => controller.send(),
                              cursorColor: AppColors.accent,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 18 * s,
                                color: AppColors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type a message…',
                                hintStyle: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 18 * s,
                                  color: const Color(0xFF747686),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20 * s),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => Semantics(
                            button: true,
                            label: 'Send message',
                            child: Material(
                              color: kChatInner,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Color(0xFFABB7BB)),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(17 * s)),
                              ),
                              child: InkWell(
                                onTap: controller.sending.value ? null : controller.send,
                                child: SizedBox(
                                  width: 90 * s,
                                  height: double.infinity,
                                  child: Center(
                                    child: Text(
                                      'Send',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 18 * s,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
    );
  }
}
