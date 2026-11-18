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

  static const Duration _slide = Duration(milliseconds: 300);

  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  /// The web app shows "Continue" instead of "Skip" on the last slide.
  /// Set to true to restore that behaviour.
  static const bool showContinueOnLastPage = false;

  bool _isCompleting = false;

  List<OnboardingPageData> get pages => OnboardingContent.pages;

  bool get isFirstPage => currentIndex.value == 0;
  bool get isLastPage => currentIndex.value == pages.length - 1;

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  /// Android back button / back gesture: go to the previous slide first.
  Future<void> previousPage() async {
    if (isFirstPage || !pageController.hasClients) return;
    await pageController.previousPage(duration: _slide, curve: Curves.easeOutCubic);
  }

  /// "Skip": slides 1-3 go to the next slide, the last slide finishes
  /// onboarding.
  Future<void> onSkip() async {
    if (isLastPage) {
      await complete();
      return;
    }
    if (!pageController.hasClients) return;
    await pageController.nextPage(duration: _slide, curve: Curves.easeOutCubic);
  }

  /// Saves the "seen" flag and opens the dashboard. Onboarding never shows
  /// again after this (see `SplashController`).
  Future<void> complete() async {
    if (_isCompleting) return;
    _isCompleting = true;

    try {
      final saved = await _storage.setOnboardingCompleted(true);
      if (!saved) {
        AppLogger.error('Onboarding flag was not saved (setBool returned false)');
      }
    } catch (error, stackTrace) {
      // Never block the user because a preference failed to save.
      AppLogger.error('Could not persist onboarding flag', error: error, stackTrace: stackTrace);
    }

    Get.offAllNamed<void>(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
