import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';

class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({super.key, required this.match, required this.scale});

  final MatchRating match;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      margin: EdgeInsets.only(top: 54 * s),
      padding: EdgeInsets.fromLTRB(10 * s, 56 * s, 10 * s, 10 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.5 * s),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Line(scale: s),
              SizedBox(width: 14 * s),
              Text('Basant', style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ).scaled(s)),
              SizedBox(width: 14 * s),
              _Line(scale: s),
            ],
          ),
          SizedBox(height: 27 * s),
          Row(
            children: <Widget>[
              _MetricCard(icon: Icons.track_changes_outlined, value: match.goals, label: 'Goals', scale: s),
              SizedBox(width: 7 * s),
              _MetricCard(icon: Icons.volunteer_activism_outlined, value: match.assists, label: 'Assists', scale: s),
              SizedBox(width: 7 * s),
              _MetricCard(icon: Icons.shield_outlined, value: match.saves, label: 'Saves', scale: s),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) => Container(
        width: 35 * scale,
        height: 2.5 * scale,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(2 * scale),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, required this.scale});

  final IconData icon;
  final int value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Expanded(
      child: Container(
        height: 102 * s,
        padding: EdgeInsets.only(top: 10 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF3F6357),
          borderRadius: BorderRadius.circular(12 * s),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0xFF30584D), offset: Offset(0, 2), blurRadius: 0),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 39 * s,
              height: 39 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.accent, width: 1.2 * s),
              ),
              child: Icon(icon, color: AppColors.accent, size: 23 * s),
            ),
            SizedBox(height: 7 * s),
            Text('$value', style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ).scaled(s)),
            Text(label, style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ).scaled(s)),
          ],
        ),
      ),
    );
  }
}
