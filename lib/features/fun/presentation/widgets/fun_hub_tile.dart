import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// "Challenges" / "Quizzes" tile of the Fun hub (green bottom edge).
class FunHubTile extends StatelessWidget {
  const FunHubTile({
    super.key,
    required this.label,
    required this.asset,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final String asset;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(20 * s);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            height: 149.7 * s,
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: radius),
            // The accent shows as a 2pt edge under the tile.
            padding: EdgeInsets.only(bottom: 2 * s),
            child: DecoratedBox(
              decoration: BoxDecoration(color: FunColors.hubTile, borderRadius: radius),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8.7 * s),
                  SizedBox(
                    width: 89 * s,
                    height: 89 * s,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 13 * s),
                  Text(label, style: FunTextStyles.hubLabel.copyWith(fontSize: 16 * s)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
