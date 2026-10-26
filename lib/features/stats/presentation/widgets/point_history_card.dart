import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';

class PointHistoryCard extends StatelessWidget {
  const PointHistoryCard({super.key, required this.entry, required this.scale});

  final PointHistoryEntry entry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.fromLTRB(10 * s, 9 * s, 10 * s, 8 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.5 * s),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: AppColors.white,
            ).scaled(s),
          ),
          SizedBox(height: 5 * s),
          Text(
            entry.date,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.textMuted,
            ).scaled(s),
          ),
          SizedBox(height: 5 * s),
          RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '\$ ${entry.points} ',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.accent,
                  ).scaled(s),
                ),
                TextSpan(
                  text: 'Points',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ).scaled(s),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
