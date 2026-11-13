import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/chats_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

const Color _panel = Color(0xFF132B36);
const Color _panelHead = Color(0xFF1B3D4A);
const Color _mine = Color(0xFF335F4B);
const Color _theirs = Color(0xFF1B3A47);

class ChatsPage extends GetView<ChatsController> {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    return Obx(() {
      final player = controller.selected.value;
      return PopScope(
        canPop: player == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.close();
        },
        child: SubPageScaffold(
          title: 'Chats',
          navIndex: -1,
          body: Padding(
            padding: EdgeInsets.fromLTRB(r.gutter + 12 * s, 12 * s, r.gutter + 12 * s, 12 * s),
            child: Container(
              decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(24 * s)),
              clipBehavior: Clip.antiAlias,
              child: player == null ? _PlayerList(controller: controller, scale: s) : _Conversation(controller: controller, player: player, scale: s),
            ),
          ),
        ),
      );
    });
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.controller, required this.scale});
  final ChatsController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      margin: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(color: const Color(0xFF1A3A47), borderRadius: BorderRadius.circular(22 * s)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
            child: Text('Players', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 22 * s, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) return const AppLoader();
              final list = controller.players.toList();
              if (list.isEmpty) return const CoachEmpty(text: 'No players to chat with yet.');
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => Material(
                  color: const Color(0xFF265364),
                  child: InkWell(
                    onTap: () => controller.open(list[i]),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 14 * s),
                      child: Row(
                        children: <Widget>[
                          CoachPlayerAvatar(url: list[i].photoUrl, size: 48 * s),
                          SizedBox(width: 16 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(list[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w500)),
                                Text('Tap to chat', style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 16 * s)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({required this.controller, required this.player, required this.scale});
  final ChatsController controller;
  final CoachPlayer player;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      // Keeps the input above the keyboard on every Android / iOS version.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: <Widget>[
          Container(
            color: _panelHead,
            padding: EdgeInsets.fromLTRB(8 * s, 10 * s, 16 * s, 10 * s),
            child: Row(
              children: <Widget>[
                IconButton(tooltip: 'Back', onPressed: controller.close, icon: Icon(Icons.arrow_back, color: AppColors.white, size: 22 * s)),
                SizedBox(width: 8 * s),
                CoachPlayerAvatar(url: player.photoUrl, size: 40 * s),
                SizedBox(width: 14 * s),
                Expanded(child: Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 19 * s, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loadingMessages.value) return const AppLoader();
              final list = controller.messages.toList();
              if (list.isEmpty) return const CoachEmpty(text: 'No messages yet. Say hi!');
              return ListView.builder(
                controller: controller.scroll,
                padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 12 * s),
                itemCount: list.length,
                itemBuilder: (_, i) => _Bubble(msg: list[i], scale: s),
              );
            }),
          ),
          Container(
            color: _panelHead,
            padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 12 * s),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller.input,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.send(),
                    cursorColor: AppColors.accent,
                    style: AppTextStyles.fieldText.scaled(s),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.fieldHint.scaled(s),
                      filled: true,
                      fillColor: const Color(0xFF2D4F5C),
                      contentPadding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 14 * s),
                      border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(16 * s)), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(16 * s)), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(16 * s)), borderSide: const BorderSide(color: AppColors.selectGreen)),
                    ),
                  ),
                ),
                Obx(
                  () => Material(
                    color: const Color(0xFF1B3A47),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(16 * s)), side: const BorderSide(color: AppColors.cardBorder)),
                    child: InkWell(
                      onTap: controller.canSend.value ? controller.send : null,
                      child: Container(
                        height: 52 * s,
                        constraints: BoxConstraints(minWidth: 84 * s),
                        alignment: Alignment.center,
                        child: Text('Send', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 18 * s, fontWeight: FontWeight.w600, color: controller.canSend.value ? AppColors.accent : AppColors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, required this.scale});
  final ChatMessage msg;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final meta = AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 13 * s);
    return Align(
      alignment: msg.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * s),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.68),
        padding: EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 10 * s),
        decoration: BoxDecoration(
          color: msg.mine ? _mine : _theirs,
          borderRadius: BorderRadius.circular(18 * s),
          border: msg.mine ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(msg.text, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400)),
            SizedBox(height: 8 * s),
            Wrap(
              spacing: 10 * s,
              children: <Widget>[Text(formatChatTime(msg.time), style: meta), if (msg.mine && msg.seen) Text('Seen', style: meta)],
            ),
          ],
        ),
      ),
    );
  }
}
