import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_bottom_nav.dart';
import 'package:ecoach_pro/features/dashboard/data/models/banner_model.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/program.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/banner_view.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/profile_card.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/program_tile.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/stats_grid.dart';

/// Signed-in home: banners -> profile -> Your Stats -> Popular Programs ->
/// Keep Going. Pull down to refresh.
class MemberBody extends StatelessWidget {
  const MemberBody({
    super.key,
    required this.banners,
    required this.name,
    required this.stats,
    required this.programs,
    required this.monthlyPoints,
    required this.navBottomInset,
    required this.onRefresh,
    this.subtitle,
    this.photoUrl,
    this.flag,
    this.onStatTap,
    this.onProgramTap,
    this.onEarnPoints,
    this.onRedeemPoints,
  });

  final List<BannerModel> banners;
  final String name;
  final String? subtitle;
  final String? photoUrl;
  final String? flag;
  final List<DashboardStat> stats;
  final List<Program> programs;
  final String monthlyPoints;
  final double navBottomInset;
  final Future<void> Function() onRefresh;
  final ValueChanged<DashboardStat>? onStatTap;
  final ValueChanged<Program>? onProgramTap;
  final VoidCallback? onEarnPoints;
  final VoidCallback? onRedeemPoints;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    Widget title(String text, {double top = 21.6}) => SliverPadding(
      padding: EdgeInsets.fromLTRB(hPad, top * s, hPad, 12 * s),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Text(text, style: AppTextStyles.sectionTitle.scaled(s)),
        ),
      ),
    );

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          if (banners.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 21 * s, hPad, 0),
              sliver: SliverToBoxAdapter(
                child: BannerView(banners: banners, scale: s),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 21 * s, hPad, 0),
            sliver: SliverToBoxAdapter(
              child: ProfileCard(
                name: name,
                subtitle: subtitle,
                photoUrl: photoUrl,
                flag: flag,
                scale: s,
              ),
            ),
          ),
          title('Your Stats'),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            sliver: SliverToBoxAdapter(
              child: StatsGrid(stats: stats, scale: s, onTap: onStatTap),
            ),
          ),
          title('Popular Programs'),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            sliver: SliverList.separated(
              itemCount: programs.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.7 * s),
              itemBuilder: (context, index) => ProgramTile(
                program: programs[index],
                scale: s,
                onTap: onProgramTap == null
                    ? null
                    : () => onProgramTap!(programs[index]),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24 * s, hPad, 0),
            sliver: SliverToBoxAdapter(
              child: _KeepGoingCard(
                scale: s,
                points: monthlyPoints,
                onEarn: onEarnPoints,
                onRedeem: onRedeemPoints,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBottomNav.designHeight * s + navBottomInset + 24 * s,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepGoingCard extends StatelessWidget {
  const _KeepGoingCard({
    required this.scale,
    required this.points,
    this.onEarn,
    this.onRedeem,
  });

  final double scale;
  final String points;
  final VoidCallback? onEarn;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 18 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * s),
        border: Border.all(color: AppColors.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF17513A), Color(0xFF0B3520)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Keep Going, Champion!',
            style: AppTextStyles.sectionTitle.scaled(s),
          ),
          SizedBox(height: 8 * s),
          Text(
            'You collected $points points this month so far',
            style: AppTextStyles.programDesc
                .scaled(s)
                .copyWith(color: AppColors.white),
          ),
          SizedBox(height: 14 * s),
          Wrap(
            spacing: 8 * s,
            runSpacing: 8 * s,
            children: <Widget>[
              _Pill(label: 'Earn More Points', scale: s, onTap: onEarn),
              _Pill(label: 'Redeem Points', scale: s, onTap: onRedeem),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.scale, this.onTap});

  final String label;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.selectGreen,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 8 * scale,
          ),
          child: Text(label, style: AppTextStyles.heroButton.scaled(scale)),
        ),
      ),
    );
  }
}
