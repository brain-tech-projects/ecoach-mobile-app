import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_strings.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_background.dart';
import 'package:ecoach_pro/core/widgets/app_logo.dart';
import 'package:ecoach_pro/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:ecoach_pro/features/onboarding/presentation/widgets/onboarding_action_button.dart';
import 'package:ecoach_pro/features/onboarding/presentation/widgets/onboarding_page_item.dart';
import 'package:ecoach_pro/features/onboarding/presentation/widgets/page_indicator.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    // Web layout: logo top = 42 pt, "Skip" centre = 54 pt from the bottom.
    // On notched / gesture-nav phones keep clear of the system insets.
    final logoTop = math.max(r.s(42), r.safeTop + r.s(8));
    final bottomPadding = math.max(r.s(30), r.safeBottom + r.s(6));

    final scaffold = Scaffold(
      body: AppBackground(
        child: Column(
          children: <Widget>[
            SizedBox(height: logoTop),
            AppLogo(scale: r.scale),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) => OnboardingPageItem(data: controller.pages[index]),
              ),
            ),
            Obx(() => PageIndicator(count: controller.pages.length, currentIndex: controller.currentIndex.value, scale: r.scale)),
            SizedBox(height: r.s(18)),

            Obx(
              () => OnboardingActionButton(
                label: controller.isLastPage ? AppStrings.continueLabel : AppStrings.skip,
                onPressed: controller.continueOnboarding,
                scale: r.scale,
              ),
            ),

            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );

    return Obx(
      () => PopScope(
        canPop: controller.isFirstPage,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.previousPage();
        },
        child: scaffold,
      ),
    );
  }
}
