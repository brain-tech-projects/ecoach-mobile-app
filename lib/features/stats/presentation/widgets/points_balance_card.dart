import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// "Your Current Points 185.00" card at the top of the Trophy Room.
class PointsBalanceCard extends StatelessWidget {
  const PointsBalanceCard({
    super.key,
    required this.points,
    required this.scale,
    required this.onHistoryTap,
  });

  final double points;
  final double scale;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final value = points.toStringAsFixed(2);

    return Semantics(
      container: true,
      label: 'Your current points $value',
      child: Material(
        color: AppColors.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17 * s),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: CustomPaint(
          painter: _ArcsPainter(scale: s),
          child: SizedBox(
            height: 91.7 * s,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.7 * s),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 60 * s,
                        height: 60 * s,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(15 * s),
                          border: Border.all(color: AppColors.white, width: 2 * s),
                        ),
                        child: ExcludeSemantics(
                          child: Text(
                            r'$',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 36 * s,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * s),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Your Current Points',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: AppColors.white,
                              ).scaled(s),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                  color: AppColors.white,
                                ).scaled(s),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                Positioned(
                  top: 27.8 * s - 22,
                  right: 26 * s - 22,
                  child: IconButton(
                    onPressed: onHistoryTap,
                    tooltip: 'Points history',
                    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    padding: EdgeInsets.zero,
                    iconSize: 22 * s,
                    color: AppColors.white,
                    icon: const Icon(Icons.person_add_alt_outlined),
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

/// Soft arcs in the card background.
class _ArcsPainter extends CustomPainter {
  const _ArcsPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3F5256);
    canvas.drawCircle(Offset(size.width * 0.78, -20 * scale), 80 * scale, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height + 40 * scale), 70 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcsPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
