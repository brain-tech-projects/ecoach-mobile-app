// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:ecoach_pro/app/routes/app_routes.dart';
// import 'package:ecoach_pro/core/storage/local_storage.dart';
// import 'package:ecoach_pro/core/utils/logger.dart';
// import 'package:ecoach_pro/features/onboarding/data/onboarding_content.dart';
// import 'package:ecoach_pro/features/onboarding/domain/entities/onboarding_page_data.dart';

// class OnboardingController extends GetxController {
//   OnboardingController(this._storage);

//   final LocalStorage _storage;

//   final PageController pageController = PageController();
//   final RxInt currentIndex = 0.obs;

//   bool _isCompleting = false;

//   List<OnboardingPageData> get pages => OnboardingContent.pages;

//   bool get isFirstPage => currentIndex.value == 0;
//   bool get isLastPage => currentIndex.value == pages.length - 1;

//   void onPageChanged(int index) => currentIndex.value = index;

//   /// Android back button / back gesture: go to the previous slide first.
//   Future<void> previousPage() async {
//     if (isFirstPage || !pageController.hasClients) return;
//     await pageController.previousPage(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOutCubic,
//     );
//   }

//   /// "Skip" (slides 1-3) and "Continue" (last slide) both finish onboarding.
//   Future<void> complete() async {
//     if (_isCompleting) return; // ignore double taps
//     _isCompleting = true;

//     try {
//       await _storage.setOnboardingCompleted(true);
//     } catch (error, stackTrace) {
//       // Never block the user because a preference failed to save.
//       AppLogger.error(
//         'Could not persist onboarding flag',
//         error: error,
//         stackTrace: stackTrace,
//       );
//     }

//     Get.offAllNamed<void>(AppRoutes.login);
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }
// }







import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/onboarding/data/onboarding_content.dart';
import 'package:ecoach_pro/features/onboarding/domain/entities/onboarding_page_data.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._storage);

  final LocalStorage _storage;

  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  bool _isCompleting = false;

  List<OnboardingPageData> get pages => OnboardingContent.pages;

  bool get isFirstPage => currentIndex.value == 0;

  bool get isLastPage => currentIndex.value == pages.length - 1;

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// Go to the previous onboarding page.
  Future<void> previousPage() async {
    if (isFirstPage || !pageController.hasClients) return;

    await pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  /// Skip moves to the next page until the last page.
  /// On the last page, it completes onboarding and opens login.
  Future<void> skip() async {
    if (_isCompleting) return;

    if (!isLastPage) {
      if (!pageController.hasClients) return;

      await pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await complete();
  }

  // /// Continue advances to the next page or finishes onboarding.
  // Future<void> continueOnboarding() async {
  //   await skip();
  // }

  Future<void> continueOnboarding() async {
  if (_isCompleting) return;

  if (!isLastPage) {
    if (!pageController.hasClients) return;

    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    return;
  }

  await complete();
}

  /// Finish onboarding and navigate to login.
  Future<void> complete() async {
    if (_isCompleting) return;
    _isCompleting = true;

    try {
      await _storage.setOnboardingCompleted(true);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Could not persist onboarding flag',
        error: error,
        stackTrace: stackTrace,
      );
    }

    Get.offAllNamed<void>(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
