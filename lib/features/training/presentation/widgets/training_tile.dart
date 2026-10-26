import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Level image with the "1/23" badge (top-right) and a name pill (bottom).
class TrainingTile extends StatelessWidget {
  const TrainingTile({
    super.key,
    required this.level,
    required this.scale,
    required this.onTap,
  });

  final TrainingLevel level;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: '${level.title}, ${level.unlocked} of ${level.total}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 193 * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10 * s),
                    child: Image.asset(level.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: -5.8 * s,
                  right: -2.5 * s,
                  child: _Badge(text: '${level.unlocked}/${level.total}', scale: s),
                ),
                Positioned(
                  left: 20.3 * s,
                  right: 20.3 * s,
                  bottom: 8 * s,
                  child: _NamePill(label: level.title, scale: s),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: 49.7 * s,
      height: 49.7 * s,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(4 * s),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(text, style: AppTextStyles.tileBadge.scaled(s))),
      ),
    );
  }
}

class _NamePill extends StatelessWidget {
  const _NamePill({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 30 * s,
      padding: EdgeInsets.only(left: 18.7 * s, right: 5.7 * s),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15 * s),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tilePill.scaled(s),
            ),
          ),
          Container(
            width: 18 * s,
            height: 18 * s,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward, size: 11 * s, color: AppColors.background),
          ),
        ],
      ),
    );
  }
}
