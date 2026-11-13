import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';

class _Spec {
  const _Spec(this.label, {this.icon, this.asset});
  final String label;
  final IconData? icon;
  final String? asset;
}

const List<_Spec> _specs = <_Spec>[
  _Spec('Teams', icon: Icons.groups_outlined),
  _Spec('Players', icon: Icons.people_outline),
  _Spec('Home', asset: AppAssets.navHome),
  _Spec('Program', icon: Icons.playlist_play_rounded),
  _Spec('Profile', icon: Icons.person_outline),
];

/// Coach version of the floating tab bar (same look as [AppBottomNav]).
class CoachBottomNav extends StatelessWidget {
  const CoachBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scale,
  });

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
            Expanded(child: _Tile(spec: _specs[i], selected: i == currentIndex, scale: s, onTap: () => onTap(i))),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.spec, required this.selected, required this.scale, required this.onTap});

  final _Spec spec;
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
                  child: spec.asset != null
                      ? AppAssetIcon(spec.asset!, width: 19.3 * scale, height: 20 * scale, color: color)
                      : Icon(spec.icon, size: 21 * scale, color: color),
                ),
              ),
              SizedBox(height: 6.3 * scale),
              Text(spec.label, maxLines: 1, style: AppTextStyles.navLabel.scaled(scale).copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
