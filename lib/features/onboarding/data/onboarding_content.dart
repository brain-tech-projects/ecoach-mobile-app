import 'package:ecoach_pro/features/onboarding/domain/entities/onboarding_page_data.dart';

/// Static onboarding copy (identical to the web app, in the same order).
abstract final class OnboardingContent {
  static const List<OnboardingPageData> pages = <OnboardingPageData>[
    OnboardingPageData(
      title: 'Coaching and Training',
      chips: <String>['Professional-led Training', 'Learn the fundamentals every footballer needs', 'Increase fitness levels'],
    ),
    OnboardingPageData(
      title: 'Personalized Training Program',
      chips: <String>['Pick your favourite skills', 'Build your own sessions', 'Grow your confidence'],
    ),
    OnboardingPageData(
      title: 'Match Tracker, Challenges, Tricks and more',
      chips: <String>['Log your personal stats each week', 'Take on fun challenges', 'Record your performance from matches'],
    ),
    OnboardingPageData(
      description:
          'Take advantage of our 7 Day Free Trial across all subscriptions to '
          'show you how eCoachPro can improve your fitness and skill levels!',
    ),
  ];
}
