import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/coach_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/coach_bottom_nav.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/coach_home_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';
import 'package:ecoach_pro/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/banner_view.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/member_header.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/profile_card.dart';

/// Home for signed-in coaches. Rendered by DashboardPage when `role == Coach`
/// (header, banners and unread count reuse the existing DashboardController).
class CoachHomePage extends StatelessWidget {
  const CoachHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = Get.find<DashboardController>();
    final c = Get.isRegistered<CoachHomeController>() ? Get.find<CoachHomeController>() : Get.put(CoachHomeController());
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    final navBottom = math.max(8.7 * s, r.safeBottom);

    Widget row(Widget a, Widget b) => Padding(
      padding: EdgeInsets.only(bottom: 8.7 * s),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[Expanded(child: a), SizedBox(width: 8.7 * s), Expanded(child: b)]),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.headerBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              Obx(() {
                final user = dash.session.user.value;
                return MemberHeader(
                  name: user?.fullName ?? user?.displayName ?? '',
                  photoUrl: user?.profilePhoto,
                  unreadCount: dash.unreadCount.value,
                  onMenuTap: dash.openMenu,
                  onBellTap: dash.onBellTap,
                  onprofiletap: () => CoachNav.onTabSelected(CoachNav.profileIndex),
                );
              }),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(21 * s)),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () => Future.wait<void>(<Future<void>>[dash.loadMember(), c.load()]),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 21 * s, hPad, 0),
                            sliver: SliverToBoxAdapter(
                              child: Obx(() => dash.banners.isEmpty ? const SizedBox.shrink() : Padding(padding: EdgeInsets.only(bottom: 21 * s), child: BannerView(banners: dash.banners.toList(), scale: s))),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            sliver: SliverToBoxAdapter(
                              child: Obx(() {
                                final user = dash.session.user.value;
                                return ProfileCard(name: user?.fullName ?? user?.displayName ?? '', photoUrl: user?.profilePhoto, flag: coachFlag(user?.countryCode), scale: s);
                              }),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 21.6 * s, hPad, 12 * s),
                            sliver: SliverToBoxAdapter(child: Semantics(header: true, child: Text('Your Stats', style: AppTextStyles.sectionTitle.scaled(s)))),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            sliver: SliverToBoxAdapter(
                              child: Obx(() {
                                final st = c.stats.value;
                                return Column(
                                  children: <Widget>[
                                    row(
                                      CoachStatTile(icon: Icons.handshake_outlined, value: '${st.teams}', label: 'Teams', onTap: c.openTeams),
                                      CoachStatTile(icon: Icons.upload_file_outlined, value: '${st.trainings}', label: 'Uploaded Trainings', onTap: c.openPrograms),
                                    ),
                                    row(
                                      CoachStatTile(icon: Icons.groups_outlined, value: '${st.players}', label: 'Players', onTap: c.openPlayers),
                                      CoachCreateTile(onTap: c.createTraining),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 16 * s, hPad, 0),
                            sliver: SliverToBoxAdapter(child: CoachNotifyCard(onTap: c.notify)),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: CoachBottomNav.designHeight * s + navBottom + 24 * s)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: navBottom,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1 * s),
                  child: CoachBottomNav(currentIndex: CoachNav.homeIndex, onTap: CoachNav.onTabSelected, scale: s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
