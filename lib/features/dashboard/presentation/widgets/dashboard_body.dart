import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_bottom_nav.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/hero_banner.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/program_tile.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/stats_grid.dart';

/// Everything under the fixed header: one smooth, lazily-built scroll view
/// (hero -> stats -> popular programs). Bottom padding clears the floating nav.
class DashboardBody extends StatelessWidget {
  const DashboardBody({
    super.key,
    required this.data,
    required this.navBottomInset,
    required this.onOpenAuth,
    this.onStatTap,
    this.onJoinNow,
    this.onTakeTour,
    this.onInstallApp,
  });

  final DashboardData data;
  final double navBottomInset;
  final VoidCallback onOpenAuth;
  final ValueChanged<DashboardStat>? onStatTap;
  final VoidCallback? onJoinNow;
  final VoidCallback? onTakeTour;
  final VoidCallback? onInstallApp;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    final programs = data.programs;

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 21 * s, hPad, 0),
          sliver: SliverToBoxAdapter(
            child: HeroBanner(
              scale: s,
              onJoinNow: onJoinNow,
              onTakeTour: onTakeTour,
              onInstallApp: onInstallApp,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 24 * s, hPad, 0),
          sliver: SliverToBoxAdapter(
            child: StatsGrid(stats: data.stats, scale: s, onTap: onStatTap),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 21.6 * s, hPad, 14 * s),
          sliver: SliverToBoxAdapter(
            child: Semantics(
              header: true,
              child: Text(
                'Popular Programs',
                style: AppTextStyles.sectionTitle.scaled(s),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverList.separated(
            itemCount: programs.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.7 * s),
            itemBuilder: (context, index) => ProgramTile(
              program: programs[index],
              scale: s,
              onTap: onOpenAuth,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppBottomNav.designHeight * s + navBottomInset + 24 * s,
          ),
        ),
      ],
    );
  }
}
