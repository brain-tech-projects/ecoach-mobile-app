import 'dart:math' as math;

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_bottom_nav.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';
import 'package:ecoach_pro/features/dashboard/data/member_programs.dart';
import 'package:ecoach_pro/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/member_body.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/member_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final navBottom = math.max(8.7 * s, r.safeBottom);

    return Scaffold(
      backgroundColor: AppColors.headerBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              // Fixed (does not scroll).
              Obx(() {
                final user = controller.session.user.value;
                if (!controller.isLoggedIn || user == null) {
                  return DashboardHeader(onProfileTap: controller.openAuth, onMenuTap: controller.openMenu);
                }
                return MemberHeader(
                  name: "${user.fullName}",
                  photoUrl: user.profilePhoto,
                  unreadCount: controller.unreadCount.value,
                  onMenuTap: controller.openMenu,
                  onBellTap: controller.onBellTap,
                );
              }),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(21 * s)),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Obx(() {
                      final user = controller.session.user.value;
                      if (controller.isLoggedIn && user != null) {
                        return MemberBody(
                          banners: controller.banners.toList(),
                          name: "${user.fullName}",
                          subtitle: [user.myposition, user.club].where((e) => e != null && e.isNotEmpty).join(' . '),
                          photoUrl: user.profilePhoto,
                          flag: _flag(user.countryCode),
                          stats: controller.memberStats,
                          programs: MemberPrograms.all,
                          monthlyPoints: controller.monthlyPointsText,
                          navBottomInset: navBottom,
                          onRefresh: controller.loadMember,
                          onStatTap: controller.onStatTap,
                          onProgramTap: controller.onProgramTap,
                          onEarnPoints: controller.onEarnPoints,
                          onRedeemPoints: controller.onRedeemPoints,
                        );
                      }

                      final data = controller.data.value;
                      if (data != null) {
                        return DashboardBody(
                          data: data,
                          navBottomInset: navBottom,
                          onOpenAuth: controller.openAuth,
                          onStatTap: controller.onStatTap,
                          onJoinNow: controller.onJoinNow,
                          onTakeTour: controller.onTakeTour,
                          onInstallApp: controller.onInstallApp,
                        );
                      }
                      if (controller.errorMessage.value != null) {
                        return _ErrorView(message: controller.errorMessage.value!, onRetry: controller.load, scale: s);
                      }
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }),
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
                  child: Obx(() => AppBottomNav(currentIndex: controller.selectedTab.value, onTap: controller.onNavTap, scale: s)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _firstName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? full : parts.first;
  }

  static String? _flag(String? code) => (code == null || code.length != 2) ? null : Country(code: code, name: '').flag;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry, required this.scale});

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, style: AppTextStyles.onboardingBody.scaled(scale)),
          TextButton(
            onPressed: onRetry,
            child: Text('Retry', style: AppTextStyles.action.scaled(scale)),
          ),
        ],
      ),
    );
  }
}
