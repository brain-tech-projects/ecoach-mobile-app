import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';

const Color kChatOuter = Color(0xFF122B34);
const Color kChatInner = Color(0xFF183843);
const Color kChatHeader = Color(0xFF1C3E49);
const Color kChatLine = Color(0xFF2A5360);
const Color kChatMuted = Color(0xFF8C9194);

/// Rounded "inset" frame used by Chats and the conversation.
class ChatFrame extends StatelessWidget {
  const ChatFrame({super.key, required this.scale, required this.child, this.innerTopGap = 10});

  final double scale;
  final Widget child;
  final double innerTopGap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 20 * s, 12 * s, 20 * s),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kChatOuter,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10 * s),
            bottom: Radius.circular(30 * s),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12 * s, innerTopGap * s, 12 * s, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30 * s),
              bottom: Radius.circular(30 * s),
            ),
            child: ColoredBox(color: kChatInner, child: child),
          ),
        ),
      ),
    );
  }
}

/// Round photo of the coach (asset / network / person icon).
class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key, this.asset, this.url, required this.size});

  final String? asset;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => ColoredBox(
          color: AppColors.avatarBg,
          child: Icon(Icons.person, size: size * 0.6, color: AppColors.avatarFg),
        );
    Widget img;
    if (asset != null) {
      img = Image.asset(asset!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else if (url != null) {
      img = Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else {
      img = fallback();
    }
    return ExcludeSemantics(
      child: SizedBox(width: size, height: size, child: ClipOval(child: img)),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.scale});

  final ChatMessage message;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final mine = message.mine;
    final r = Radius.circular(20 * s);
    final time = PlayerFormat.chatTime(message.sentAt);
    final status = mine
        ? (message.status == MessageStatus.seen ? 'Seen' : 'Sent')
        : null;
    final small = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 14 * s,
      height: 1.4,
      color: const Color(0xFFC1CBCE),
    );

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 270 * s),
        child: Semantics(
          label: '${mine ? 'You' : 'Coach'}: ${message.text}. $time${status != null ? ', $status' : ''}',
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15 * s, vertical: 8 * s),
              decoration: BoxDecoration(
                color: mine ? const Color(0xFF325E49) : const Color(0xFF1B3C47),
                border: mine ? null : Border.all(color: const Color(0xFF234C57), width: 1.5),
                borderRadius: BorderRadius.only(
                  topLeft: r,
                  topRight: r,
                  bottomLeft: mine ? r : Radius.zero,
                  bottomRight: mine ? Radius.zero : r,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18 * s,
                      height: 1.4,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 1 * s),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(child: Text(time, style: small)),
                      if (status != null) ...<Widget>[
                        SizedBox(width: 12 * s),
                        Text(status, style: small),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
