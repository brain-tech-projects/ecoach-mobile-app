import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';

/// Trophy picture (asset, network or a drawn placeholder). Fills its parent
/// and clips to [radius]. [hero] uses the wide detail image when available.
class TrophyArt extends StatelessWidget {
  const TrophyArt({
    super.key,
    required this.trophy,
    required this.radius,
    this.hero = false,
  });

  final Trophy trophy;
  final double radius;
  final bool hero;

  static const Color _bg = Color(0xFF040B0A);

  @override
  Widget build(BuildContext context) {
    final detail = hero ? trophy.detailAsset : null;
    final asset = detail ?? trophy.imageAsset;
    final fit = detail != null ? BoxFit.cover : (hero ? BoxFit.contain : BoxFit.cover);

    Widget image;
    if (asset != null) {
      image = Image.asset(
        asset,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => const _Placeholder(),
      );
    } else if (trophy.imageUrl != null) {
      image = Image.network(
        trophy.imageUrl!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const _Placeholder(),
      );
    } else {
      image = const _Placeholder();
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(color: _bg, child: image),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF0F3A2F), Color(0xFF040B0A)],
          ),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.45,
            heightFactor: 0.45,
            child: FittedBox(
              child: Icon(Icons.emoji_events, color: AppColors.accent),
            ),
          ),
        ),
      );
}
