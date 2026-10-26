import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';

class _NavSpec {
  const _NavSpec(this.label, this.asset, this.width, this.height);

  final String label;
  final String asset;
  final double width; // design points
  final double height;
}

const List<_NavSpec> _specs = <_NavSpec>[
  _NavSpec('Training', AppAssets.navTraining, 16.7, 16.7),
  _NavSpec('Skills', AppAssets.navSkills, 20, 20),
  _NavSpec('Home', AppAssets.navHome, 19.3, 20),
  _NavSpec('Fun', AppAssets.navFun, 19.3, 19.3),
  _NavSpec('Tracker', AppAssets.navTracker, 20, 20),
];

/// Floating rounded bottom navigation bar.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scale,
  });

  /// Height in design points (multiply by scale).
  static const double designHeight = 65;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      height: designHeight * s,
      padding: EdgeInsets.symmetric(horizontal: 6.3 * s),
      decoration: BoxDecoration(
        color: AppColors.navBg,
        borderRadius: BorderRadius.circular(29 * s),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < _specs.length; i++)
            Expanded(
              child: _NavTile(
                spec: _specs[i],
                selected: i == currentIndex,
                scale: s,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.spec,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.white;

    return Semantics(
      button: true, 
      selected: selected,
      label: spec.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20 * scale,
                child: Center(
                  child: AppAssetIcon(
                    spec.asset,
                    width: spec.width * scale,
                    height: spec.height * scale,
                    color: color,
                  ),
                ),
              ),
              SizedBox(height: 6.3 * scale),
              Text(
                spec.label,
                maxLines: 1,
                style: AppTextStyles.navLabel
                    .scaled(scale)
                    .copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
