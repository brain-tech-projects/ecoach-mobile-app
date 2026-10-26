import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Level title on the left, circular progress ("4%") on the right.
class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({
    super.key,
    required this.level,
    required this.scale,
    this.onTap,
  });

  final TrainingLevel level;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11 * s),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 86.3 * s,
          child: Padding(
            padding: EdgeInsets.fromLTRB(17.3 * s, 0, 21 * s, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 6 * s),
                    child: Text(
                      level.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.levelTitle.scaled(s),
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.7 * s,
                  height: 56.7 * s,
                  child: CustomPaint(
                    painter: _RingPainter(progress: level.progress, scale: s),
                    child: Center(
                      child: Text(
                        '${level.percent}%',
                        style: AppTextStyles.levelPercent.scaled(s),
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
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.scale});

  final double progress;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.7 * scale;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.ringTrack;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.accent;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.scale != scale;
}
