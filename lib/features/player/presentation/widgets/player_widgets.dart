import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

const Color kRemoveRed = Color(0xFFEC5E58);

/// Underlined tab bar (All Skills | Challenges ...). Scrolls sideways on very
/// narrow screens / large font sizes instead of overflowing.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.scale,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          children: <Widget>[
            for (var i = 0; i < labels.length; i++)
              Semantics(
                button: true,
                selected: i == selected,
                label: labels[i],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18 * s),
                          child: ExcludeSemantics(
                            child: Text(
                              labels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 15 * s,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                color: i == selected ? AppColors.accent : AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7.3 * s),
                        Container(
                          height: 2.7 * s,
                          color: i == selected ? AppColors.accent : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Square thumbnail from an `assets/...` path or `https://...` URL, with a
/// dark placeholder when empty / broken.
class ThumbImage extends StatelessWidget {
  const ThumbImage({super.key, required this.source, required this.size, required this.radius});

  final String? source;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    Widget placeholder() => ColoredBox(
          color: const Color(0xFF102229),
          child: Center(
            child: Icon(Icons.image_outlined, size: size * 0.45, color: AppColors.hint),
          ),
        );
    final src = source;
    Widget child;
    if (src == null || src.isEmpty) {
      child = placeholder();
    } else if (src.startsWith('http')) {
      child = Image.network(src, fit: BoxFit.cover, cacheWidth: px,
          errorBuilder: (_, _, _) => placeholder());
    } else {
      child = Image.asset(src, fit: BoxFit.cover, cacheWidth: px,
          errorBuilder: (_, _, _) => placeholder());
    }
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
      ),
    );
  }
}

/// Thin chevron (pointing down, or up when [up]).
class ThinChevron extends StatelessWidget {
  const ThinChevron({super.key, required this.up, required this.color, required this.scale});

  final bool up;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(22 * scale, 22 * scale),
        painter: _ChevronPainter(up: up, color: color, width: 1.8 * scale),
      );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.up, required this.color, required this.width});

  final bool up;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final y1 = up ? h * 0.62 : h * 0.38;
    final y2 = up ? h * 0.38 : h * 0.62;
    final path = Path()
      ..moveTo(w * 0.12, y1)
      ..lineTo(w * 0.5, y2)
      ..lineTo(w * 0.88, y1);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter old) =>
      old.up != up || old.color != color || old.width != width;
}

/// Red circled cross used to remove an item.
class RemoveIcon extends StatelessWidget {
  const RemoveIcon({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.highlight_off, size: size, color: kRemoveRed);
}

/// Dark rounded row used by My Skills.
class SavedItemCard extends StatelessWidget {
  const SavedItemCard({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.scale,
    required this.onTap,
    required this.onRemove,
  });

  final String title;
  final String? thumbnail;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = BorderRadius.circular(20 * s);
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 66 * s),
            padding: EdgeInsets.fromLTRB(10.7 * s, 10.5 * s, 4 * s, 10.5 * s),
            child: Row(
              children: <Widget>[
                ThumbImage(source: thumbnail, size: 45 * s, radius: 10 * s),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.menuItem.scaled(s).copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Remove $title',
                  child: IconButton(
                    onPressed: onRemove,
                    constraints: BoxConstraints.tightFor(width: 48 * s.clamp(1, 1.3), height: 48 * s.clamp(1, 1.3)),
                    padding: EdgeInsets.zero,
                    icon: RemoveIcon(size: 24 * s),
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

/// Retry text shown when a list fails to load.
class RetryMessage extends StatelessWidget {
  const RetryMessage({super.key, required this.message, required this.onRetry, required this.scale});

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, style: AppTextStyles.programDesc.scaled(scale)),
            TextButton(
              onPressed: onRetry,
              child: Text('Retry', style: AppTextStyles.action.scaled(scale)),
            ),
          ],
        ),
      );
  
  }
