import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/auth/domain/entities/choice.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/selection_controls.dart';

/// Selectable row with an icon, a label and a checkbox (multiple choice) or a
/// round tick (single choice). Icons are 44 pt canvases centred 38.3 pt from
/// the card's left edge.
class ChoiceOptionCard extends StatelessWidget {
  const ChoiceOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.multiple,
    required this.onTap,
    this.scale = 1.0,
  });

  final ChoiceOption option;
  final bool selected;
  final bool multiple;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final icon = option.iconAsset;

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 56.7 * s,
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
                if (icon != null)
                  Positioned(
                    left: 15.3 * s,
                    top: 5.35 * s,
                    child: AppAssetIcon(
                      icon,
                      width: 44 * s,
                      height: 44 * s,
                      color: selected ? AppColors.selectGreen : AppColors.white,
                    ),
                  ),
                Positioned(
                  left: 71.3 * s,
                  right: 54 * s,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.optionLabel.scaled(s),
                    ),
                  ),
                ),
                Positioned(
                  right: (multiple ? 22 : 19.7) * s,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: multiple
                        ? SquareCheck(selected: selected, scale: s)
                        : CircleCheck(selected: selected, scale: s),
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
