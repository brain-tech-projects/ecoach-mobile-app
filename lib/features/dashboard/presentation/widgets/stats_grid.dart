import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';

/// 2-column grid of stat tiles (rows keep equal heights).
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.stats,
    required this.scale,
    this.onTap,
  });

  final List<DashboardStat> stats;
  final double scale;
  final ValueChanged<DashboardStat>? onTap;

  @override
  Widget build(BuildContext context) {
    final gap = 8.7 * scale;
    final rows = <Widget>[];

    for (var i = 0; i < stats.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: gap));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _StatCard(stat: stats[i], scale: scale, onTap: onTap),
              ),
              SizedBox(width: gap),
              Expanded(
                child: i + 1 < stats.length
                    ? _StatCard(stat: stats[i + 1], scale: scale, onTap: onTap)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.scale, this.onTap});

  final DashboardStat stat;
  final double scale;
  final ValueChanged<DashboardStat>? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * s),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(stat),
        child: CustomPaint(
          painter: _CirclesPainter(scale: s),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 122.7 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(11 * s, 14 * s, 11 * s, 12 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppAssetIcon(stat.iconAsset, width: 18 * s, height: 18 * s),
                  SizedBox(height: 6 * s),
                  Text(stat.value, style: AppTextStyles.statValue.scaled(s)),
                  SizedBox(height: 3 * s),
                  Text(stat.label, style: AppTextStyles.statLabel.scaled(s)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The two soft circles in the top-right of each tile (clipped by the card).
class _CirclesPainter extends CustomPainter {
  const _CirclesPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.cardCircle;
    canvas.drawCircle(Offset(142.7 * scale, 70 * scale), 36.7 * scale, paint);
    canvas.drawCircle(Offset(149.3 * scale, 20 * scale), 21.7 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _CirclesPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
