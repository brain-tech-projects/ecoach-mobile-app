import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_bottom_nav.dart';
import 'package:ecoach_pro/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/dashboard_header.dart';

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
              DashboardHeader(
                onProfileTap: controller.openAuth,
                onMenuTap: controller.openMenu,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(21 * s),
                  ),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Obx(() {
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
                        return _ErrorView(
                          message: controller.errorMessage.value!,
                          onRetry: controller.load,
                          scale: s,
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
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
                  child: Obx(
                    () => AppBottomNav(
                      currentIndex: controller.selectedTab.value,
                      onTap: controller.onNavTap,
                      scale: s,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.scale,
  });

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
