import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/rating_tracker_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/rating_skill_row.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/rating_summary_card.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/shield_avatar.dart';

class RatingTrackerPage extends GetView<RatingTrackerController> {
  const RatingTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return SubPageScaffold(
      title: 'Rating Tracker',
      navIndex: 4,
      floatingAction: SizedBox(
        width: 60 * r.scale,
        height: 60 * r.scale,
        child: Material(
          color: AppColors.accent,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => controller.showAddMatch(context),
            child: Center(
              child: Icon(Icons.add, color: AppColors.black, size: 30 * r.scale),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        if (controller.matches.isEmpty) {
          return Center(
            child: Text(
              'No matches tracked yet.',
              style: AppTextStyles.programDesc.scaled(r.scale),
            ),
          );
        }
        return _TrackerBody(controller: controller, scale: r.scale);
      }),
    );
  }
}

class _TrackerBody extends StatelessWidget {
  const _TrackerBody({required this.controller, required this.scale});

  final RatingTrackerController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = scale;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24 * s, 22 * s, 24 * s, 0),
              sliver: SliverToBoxAdapter(
                child: _CurrentMatchHeader(match: controller.matches.first, scale: s),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(21 * s, 20 * s, 21 * s, 0),
              sliver: SliverToBoxAdapter(
                child: RatingSkillRow(match: controller.matches.first, scale: s),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24 * s, 20 * s, 24 * s, 0),
              sliver: SliverToBoxAdapter(
                child: Text('2026', style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ).scaled(s)),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24 * s, 11 * s, 24 * s, 20 * s),
              sliver: SliverList.separated(
                itemCount: controller.matches.length,
                separatorBuilder: (_, _) => SizedBox(height: 10 * s),
                itemBuilder: (context, index) => _MatchTile(
                  match: controller.matches[index],
                  scale: s,
                  expanded: controller.expanded.contains(controller.matches[index].id),
                  onTap: () => controller.toggle(controller.matches[index].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentMatchHeader extends StatelessWidget {
  const _CurrentMatchHeader({required this.match, required this.scale});

  final MatchRating match;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        RatingSummaryCard(match: match, scale: s),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(child: ShieldAvatar(scale: s)),
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.scale, required this.expanded, required this.onTap});

  final MatchRating match;
  final double scale;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.5 * s),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10 * s),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 50 * s,
                    height: 50 * s,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9 * s),
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0xFF7182B7), Color(0xFF273B79)],
                      ),
                    ),
                    child: const Icon(Icons.sports_soccer, color: Colors.white70),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(match.name, style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ).scaled(s)),
                        SizedBox(height: 2 * s),
                        Text(match.date, style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ).scaled(s)),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                    size: 25 * s,
                  ),
                ],
              ),
              if (expanded) ...[
                SizedBox(height: 12 * s),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Goals ${match.goals}  •  Assists ${match.assists}  •  Saves ${match.saves}',
                    style: AppTextStyles.programDesc.scaled(s),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
