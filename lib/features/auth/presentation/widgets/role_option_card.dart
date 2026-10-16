import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/selection_controls.dart';

/// Per-role visual metrics measured from the web design (design points).
class _RoleVisual {
  const _RoleVisual({
    required this.asset,
    required this.iconWidth,
    required this.iconHeight,
    required this.cardHeight,
    required this.iconCenterX,
    required this.textLeft,
  });

  final String asset;
  final double iconWidth;
  final double iconHeight;
  final double cardHeight;
  final double iconCenterX; // from the card's left edge
  final double textLeft; // from the card's left edge
}

const Map<UserRole, _RoleVisual> _visuals = <UserRole, _RoleVisual>{
  UserRole.player: _RoleVisual(
    asset: AppAssets.iconPlayer,
    iconWidth: 36.3,
    iconHeight: 40,
    cardHeight: 72.7,
    iconCenterX: 42.2,
    textLeft: 83,
  ),
  UserRole.coach: _RoleVisual(
    asset: AppAssets.iconWhistle,
    iconWidth: 46,
    iconHeight: 46,
    cardHeight: 67.7,
    iconCenterX: 44,
    textLeft: 83,
  ),
  UserRole.parent: _RoleVisual(
    asset: AppAssets.iconParents,
    iconWidth: 38.3,
    iconHeight: 29.3,
    cardHeight: 70.7,
    iconCenterX: 45.5,
    textLeft: 86,
  ),
};

/// Selectable "I'm a Player / Coach / Parent" card.
class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
    this.scale = 1.0,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  static const double _centerY = 34.5; // content centre line from card top

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final v = _visuals[role]!;

    return Semantics(
      button: true,
      selected: selected,
      label: role.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: v.cardHeight * s,
            decoration: BoxDecoration(
              color: selected ? AppColors.selectedFill : Colors.transparent,
              border: Border.all(
                color: selected
                    ? AppColors.selectGreen
                    : AppColors.unselectedBorder,
              ),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: (v.iconCenterX - v.iconWidth / 2) * s,
                  top: (_centerY - v.iconHeight / 2) * s,
                  child: AppAssetIcon(
                    v.asset,
                    width: v.iconWidth * s,
                    height: v.iconHeight * s,
                    color: selected ? AppColors.selectGreen : AppColors.white,
                  ),
                ),
                Positioned(
                  left: v.textLeft * s,
                  top: (_centerY - 12) * s,
                  child: Text(
                    role.label,
                    style: AppTextStyles.optionLabel.scaled(s),
                  ),
                ),
                Positioned(
                  right: 20.7 * s,
                  top: (_centerY - 13) * s,
                  child: CircleCheck(selected: selected, scale: s),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
