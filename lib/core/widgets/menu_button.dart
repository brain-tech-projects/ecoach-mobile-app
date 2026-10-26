import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';

/// Round grey button with the three small horizontal lines (opens the menu).
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.scale, this.onTap});

  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Menu',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: const BoxDecoration(
            color: AppColors.menuCircle,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppAssetIcon(
              AppAssets.iconMenu,
              width: 14.7 * scale,
              height: 12.7 * scale,
            ),
          ),
        ),
      ),
    );
  }
}
