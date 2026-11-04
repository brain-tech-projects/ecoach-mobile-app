import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item, required this.scale});

  final AppNotification item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final ago = PlayerFormat.ago(item.createdAt);
    return Semantics(
      container: true,
      label: '${item.title}. ${item.body}. $ago',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11 * s, vertical: 9.5 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF183542),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              _KindTile(kind: item.kind, scale: s),
              SizedBox(width: 16 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Padding(
                          padding: EdgeInsets.only(top: 2 * s),
                          child: Text(
                            ago,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14 * s,
                              color: AppColors.descGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14 * s,
                        height: 1.4,
                        color: AppColors.descGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindTile extends StatelessWidget {
  const _KindTile({required this.kind, required this.scale});

  final NotificationKind kind;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final quiz = kind == NotificationKind.quiz;
    return Container(
      width: 48 * s,
      height: 48 * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFB8FFDB),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Container(
        width: 40 * s,
        height: 40 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: quiz ? const Color(0xFF7C4DE0) : const Color(0xFFA9EDCF),
          borderRadius: BorderRadius.circular(10 * s),
        ),
        child: Icon(
          quiz ? Icons.chat_bubble : Icons.play_arrow_rounded,
          size: (quiz ? 20 : 24) * s,
          color: quiz ? AppColors.black : AppColors.white,
        ),
      ),
    );
  }
}
