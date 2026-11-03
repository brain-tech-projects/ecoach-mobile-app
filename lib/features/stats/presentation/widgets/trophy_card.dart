import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/trophy_art.dart';

const Color _trophyCardFill = Color(0xFF264D40);
const Color _trophyCardBorder = Color(0xFF4F8961);

TextStyle _name(double s) => const TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: AppColors.white,
    ).scaled(s);

/// Green card whose picture sits half on top of it (Trophy Room tiles).
class TrophyCardShell extends StatelessWidget {
  const TrophyCardShell({
    super.key,
    required this.trophy,
    required this.scale,
    required this.child,
    this.onTap,
    this.semanticLabel,
  });

  final Trophy trophy;
  final double scale;
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final art = 75 * s;
    final overlap = art / 2;

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: overlap),
            child: Material(
              color: _trophyCardFill,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * s),
                side: const BorderSide(color: _trophyCardBorder),
              ),
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      19 * s,
                      overlap + 12.7 * s,
                      19 * s,
                      18.7 * s,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onTap,
                child: SizedBox(
                  width: art,
                  height: art,
                  child: TrophyArt(trophy: trophy, radius: 15 * s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "500 Points" pill.
class TrophyPointsPill extends StatelessWidget {
  const TrophyPointsPill({super.key, required this.points, required this.scale});

  final int points;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minHeight: 32 * s),
      padding: EdgeInsets.symmetric(horizontal: 20 * s),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Text(
        '$points Points',
        style: AppTextStyles.buttonLabelSmall.scaled(s * 14 / 15),
      ),
    );
  }
}

/// Trophy Room tile: name + points pill. Tap opens the redeem page.
class TrophyCard extends StatelessWidget {
  const TrophyCard({
    super.key,
    required this.trophy,
    required this.scale,
    required this.onTap,
  });

  final Trophy trophy;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return TrophyCardShell(
      trophy: trophy,
      scale: s,
      onTap: onTap,
      semanticLabel: '${trophy.name}, ${trophy.points} points',
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(trophy.name, style: _name(s)),
            SizedBox(height: 8.7 * s),
            TrophyPointsPill(points: trophy.points, scale: s),
          ],
        ),
      ),
    );
  }
}

/// "My Trophies" tile: points spent, name, redeemed date.
class MyTrophyCard extends StatelessWidget {
  const MyTrophyCard({super.key, required this.item, required this.scale});

  final MyTrophy item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return TrophyCardShell(
      trophy: item.trophy,
      scale: s,
      semanticLabel: '${item.trophy.name}, redeemed ${item.redeemedLabel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.points.toStringAsFixed(2),
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.accent,
            ).scaled(s),
          ),
          SizedBox(height: 10 * s),
          Text(item.trophy.name, style: _name(s)),
          SizedBox(height: 4 * s),
          Text(
            item.redeemedLabel,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: AppColors.textMuted,
            ).scaled(s),
          ),
        ],
      ),
    );
  }
}

/// Two tiles per row; the row is as tall as the taller tile.
class TrophyGridRow extends StatelessWidget {
  const TrophyGridRow({super.key, required this.left, this.right, required this.scale});

  final Widget left;
  final Widget? right;
  final double scale;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: left),
          SizedBox(width: 8 * scale),
          Expanded(child: right ?? const SizedBox.shrink()),
        ],
      );
}
