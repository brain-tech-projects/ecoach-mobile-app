import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Photo tile with the skill name in a pill that straddles its bottom edge.
class SkillTile extends StatelessWidget {
  const SkillTile({
    super.key,
    required this.category,
    required this.scale,
    required this.onTap,
  });

  final SkillCategory category;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: category.name,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 161.7 * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 144.7 * s,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10 * s),
                    child: Image.asset(category.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 125 * s,
                  child: Center(
                    child: Container(
                      height: 36.7 * s,
                      padding: EdgeInsets.symmetric(horizontal: 23 * s),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.skillPillFill,
                        border: Border.all(color: AppColors.skillPillBorder),
                        borderRadius: BorderRadius.circular(18.4 * s),
                      ),
                      child: Text(
                        category.name,
                        maxLines: 1,
                        style: AppTextStyles.skillPill.scaled(s),
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
  }
}
