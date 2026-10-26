import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';

class RatingSkillRow extends StatelessWidget {
  const RatingSkillRow({super.key, required this.match, required this.scale});

  final MatchRating match;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final values = <String, int>{
      'PAS': match.passing,
      'DRI': match.dribbling,
      'SHO': match.shooting,
      'DEF': match.defending,
      'PAC': match.pace,
      'PHY': match.physical,
    };
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.5 * s),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) Container(width: 1, height: 39 * s, color: AppColors.cardBorder),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(values.keys.elementAt(i), style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ).scaled(s)),
                  SizedBox(height: 2 * s),
                  Text('${values.values.elementAt(i)}', style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ).scaled(s)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
