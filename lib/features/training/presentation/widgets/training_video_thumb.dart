import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';

/// 90 x 81.7 pt thumbnail in the level's video row. Locked videos are dimmed
/// with a padlock; the selected one gets a green border.
class TrainingVideoThumb extends StatelessWidget {
  const TrainingVideoThumb({
    super.key,
    required this.locked,
    required this.selected,
    required this.label,
    required this.scale,
    required this.onTap,
    this.imageUrl,
  });

  final bool locked;
  final bool selected;
  final String label;
  final String? imageUrl;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final fallback = Image.asset(AppAssets.thumbActive, fit: BoxFit.cover);

    return Semantics(
      button: true,
      selected: selected,
      label: locked ? '$label, locked' : label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 90 * s,
            height: 81.7 * s,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * s),
              border: selected
                  ? Border.all(color: AppColors.selectGreen, width: 2 * s)
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (imageUrl == null)
                  fallback
                else
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback,
                  ),
                if (locked) ...<Widget>[
                  const ColoredBox(color: Color(0x8C000000)),
                  Center(
                    child: Icon(
                      Icons.lock,
                      size: 22 * s,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
