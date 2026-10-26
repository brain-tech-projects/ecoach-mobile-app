import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/play_overlay.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// List row: poster thumbnail (play mark + views badge), title, tip and a
/// "⋮" button. [onMenu] receives the button's context to anchor the popup.
class DrillCard extends StatelessWidget {
  const DrillCard({
    super.key,
    required this.drill,
    required this.scale,
    required this.onTap,
    required this.onMenu,
  });

  final Drill drill;
  final double scale;
  final VoidCallback onTap;
  final void Function(BuildContext anchor) onMenu;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final thumbWidth = 109 * s;
    final thumbHeight = thumbWidth / drill.thumbnailAspect;

    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.5 * s),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: thumbHeight,
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _Thumbnail(drill: drill, width: thumbWidth, height: thumbHeight, scale: s),
                  SizedBox(width: 12.3 * s),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 13.7 * s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            drill.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.drillTitle.scaled(s),
                          ),
                          SizedBox(height: 3 * s),
                          Text(
                            drill.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.drillDesc.scaled(s),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 7.3 * s,
                right: 7.7 * s,
                child: Builder(
                  builder: (anchor) => Semantics(
                    button: true,
                    label: 'More options',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onMenu(anchor),
                      child: SizedBox(
                        width: 24 * s,
                        height: 24 * s,
                        child: Icon(Icons.more_vert, size: 24 * s, color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.drill,
    required this.width,
    required this.height,
    required this.scale,
  });

  final Drill drill;
  final double width;
  final double height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final source = drill.thumbnail;
    final placeholder = ColoredBox(color: AppColors.ringTrack, child: SizedBox(width: width, height: height));

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          source.startsWith('http')
              ? Image.network(source, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder)
              : Image.asset(source, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
          Center(child: PlayOverlay(size: 25 * s)),
          Positioned(
            right: 7 * s,
            bottom: 8.3 * s,
            child: Container(
              height: 19 * s,
              padding: EdgeInsets.symmetric(horizontal: 9 * s),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(9.5 * s),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.visibility_outlined, size: 11 * s, color: AppColors.selectGreen),
                  SizedBox(width: 4 * s),
                  Text('${drill.views}', style: AppTextStyles.viewsCount.scaled(s)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
