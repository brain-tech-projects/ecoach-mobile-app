import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/widgets/play_overlay.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/presentation/fun_style.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// Grid card: thumbnail, favourite heart, "..." menu and title.
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.scale,
    required this.onTap,
    required this.onFavorite,
    required this.onMore,
  });

  final Challenge challenge;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  /// Receives the card's context so the menu can anchor to the card.
  final void Function(BuildContext cardContext) onMore;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Builder(
      builder: (cardContext) => Semantics(
        button: true,
        label: 'Challenge ${challenge.title}',
        child: Material(
          color: AppColors.card,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * s),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 99 * s,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      FunImage(challenge.thumbnail),
                      Center(child: PlayOverlay(size: 40 * s)),
                      Positioned(left: 0, top: 0, child: _heart(s)),
                      Positioned(right: 0, top: 0, child: _dots(s, cardContext)),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.7 * s),
                      child: Text(
                        challenge.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FunTextStyles.challengeTitle.copyWith(fontSize: 12 * s),
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

  Widget _heart(double s) => Semantics(
    button: true,
    toggled: challenge.isFavorite,
    label: challenge.isFavorite ? 'Remove from favourites' : 'Add to favourites',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onFavorite,
      child: SizedBox(
        width: 40 * s,
        height: 40 * s,
        child: Padding(
          padding: EdgeInsets.only(left: 6.8 * s, top: 7 * s),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 25.7 * s,
              height: 25.7 * s,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: FunColors.heartBackdrop),
              child: Icon(
                challenge.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: (challenge.isFavorite ? 17 : 18.5) * s,
                color: challenge.isFavorite ? FunColors.heartRed : Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _dots(double s, BuildContext cardContext) {
    Widget dot(Color c) => Container(
      width: 6 * s,
      height: 6 * s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c),
    );
    return Semantics(
      button: true,
      label: 'More options',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onMore(cardContext),
        child: SizedBox(
          width: 52 * s,
          height: 40 * s,
          child: Padding(
            padding: EdgeInsets.only(right: 8 * s),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  dot(AppColors.accent),
                  SizedBox(width: 3 * s),
                  dot(Colors.white),
                  SizedBox(width: 3 * s),
                  dot(Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
