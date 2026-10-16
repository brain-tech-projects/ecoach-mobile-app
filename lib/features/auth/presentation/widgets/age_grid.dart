import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/auth/domain/entities/choice.dart';

/// 3-column grid of big number tiles (single selection). The selected tile
/// gets a green border and a white tick badge on its top-right corner.
class AgeGrid extends StatelessWidget {
  const AgeGrid({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.scale = 1.0,
  });

  final List<ChoiceOption> options;
  final String? selectedId;
  final ValueChanged<ChoiceOption> onSelected;
  final double scale;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final gap = 8.7 * scale;
    final rows = <Widget>[];

    for (var i = 0; i < options.length; i += _columns) {
      if (i > 0) rows.add(SizedBox(height: gap));
      rows.add(
        Row(
          children: <Widget>[
            for (var j = 0; j < _columns; j++) ...<Widget>[
              if (j > 0) SizedBox(width: gap),
              Expanded(
                child: i + j < options.length
                    ? _AgeCell(
                        option: options[i + j],
                        selected: options[i + j].id == selectedId,
                        onTap: () => onSelected(options[i + j]),
                        scale: scale,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}

class _AgeCell extends StatelessWidget {
  const _AgeCell({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final ChoiceOption option;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Age ${option.label}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 87.7 * s,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.selectedFill
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? AppColors.selectGreen
                            : AppColors.unselectedBorder,
                      ),
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    child: Text(
                      option.label,
                      style: AppTextStyles.ageNumber.scaled(s),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: -4 * s,
                    right: -4.3 * s,
                    child: Container(
                      width: 26 * s,
                      height: 26 * s,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16 * s,
                        color: AppColors.selectGreen,
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
