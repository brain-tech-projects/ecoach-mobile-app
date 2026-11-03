import 'package:ecoach_pro/features/stats/presentation/pages/rating_tracker_page.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/middleware/auth_middleware.dart';
import 'package:ecoach_pro/features/subscription/presentation/bindings/subscription_binding.dart';
import 'package:ecoach_pro/features/subscription/presentation/pages/subscription_page.dart';
import 'package:ecoach_pro/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:ecoach_pro/features/auth/presentation/bindings/set_password_binding.dart';
import 'package:ecoach_pro/features/auth/presentation/bindings/sign_in_binding.dart';
import 'package:ecoach_pro/features/auth/presentation/bindings/otp_binding.dart';
import 'package:ecoach_pro/features/auth/presentation/bindings/sign_up_binding.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/otp_page.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/set_password_page.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/sign_in_page.dart';
import 'package:ecoach_pro/features/auth/presentation/pages/sign_up_page.dart';
import 'package:ecoach_pro/features/coach/presentation/bindings/coach_binding.dart';
import 'package:ecoach_pro/features/coach/presentation/pages/coach_invitation_page.dart';
import 'package:ecoach_pro/features/coach/presentation/pages/coach_training_detail_page.dart';
import 'package:ecoach_pro/features/coach/presentation/pages/coach_training_page.dart';
import 'package:ecoach_pro/features/contact/presentation/bindings/contact_binding.dart';
import 'package:ecoach_pro/features/contact/presentation/pages/contact_page.dart';
import 'package:ecoach_pro/features/dashboard/presentation/bindings/dashboard_binding.dart';
import 'package:ecoach_pro/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ecoach_pro/features/menu/presentation/bindings/side_menu_binding.dart';
import 'package:ecoach_pro/features/menu/presentation/pages/menu_page.dart';
import 'package:ecoach_pro/features/onboarding/presentation/bindings/onboarding_binding.dart';
import 'package:ecoach_pro/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:ecoach_pro/features/settings/presentation/bindings/app_settings_binding.dart';
import 'package:ecoach_pro/features/settings/presentation/pages/app_settings_page.dart';
import 'package:ecoach_pro/features/splash/presentation/bindings/splash_binding.dart';
import 'package:ecoach_pro/features/splash/presentation/pages/splash_page.dart';
import 'package:ecoach_pro/features/skills/presentation/bindings/skills_binding.dart';
import 'package:ecoach_pro/features/skills/presentation/pages/skill_detail_page.dart';
import 'package:ecoach_pro/features/skills/presentation/pages/skill_list_page.dart';
import 'package:ecoach_pro/features/skills/presentation/pages/skills_page.dart';
import 'package:ecoach_pro/features/stats/presentation/bindings/stats_binding.dart';
import 'package:ecoach_pro/features/stats/presentation/bindings/trophy_binding.dart';
import 'package:ecoach_pro/features/stats/presentation/pages/trophy_detail_page.dart';
import 'package:ecoach_pro/features/stats/presentation/pages/trophy_room_page.dart';
import 'package:ecoach_pro/features/stats/presentation/pages/trophy_store_page.dart';
import 'package:ecoach_pro/features/training/presentation/bindings/training_binding.dart';
import 'package:ecoach_pro/features/training/presentation/pages/training_detail_page.dart';
import 'package:ecoach_pro/features/training/presentation/pages/training_page.dart';
// import 'package:ecoach_pro/features/skills/presentation/bindings/skills_binding.dart';
// import 'package:ecoach_pro/features/skills/presentation/pages/skill_detail_page.dart';
// import 'package:ecoach_pro/features/skills/presentation/pages/skill_list_page.dart';
// import 'package:ecoach_pro/features/skills/presentation/pages/skills_page.dart';
// import 'package:ecoach_pro/features/training/presentation/bindings/training_binding.dart';
// import 'package:ecoach_pro/features/training/presentation/pages/training_detail_page.dart';
// import 'package:ecoach_pro/features/training/presentation/pages/training_page.dart';

abstract final class AppPages {
  static const String initial = AppRoutes.splash;

  static const Duration _fade = Duration(milliseconds: 500);

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
    GetPage<void>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
    GetPage<void>(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _fade,
    ),
    GetPage<void>(
      name: AppRoutes.signIn,
      page: () => const SignInPage(),
      binding: SignInBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.signUp,
      page: () => const SignUpPage(),
      binding: SignUpBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.otp,
      page: () => const OtpPage(),
      binding: OtpBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.subscription,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const SubscriptionPage(),
      binding: SubscriptionBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.setNewPassword,
      page: () => const SetPasswordPage(),
      binding: SetPasswordBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.menu,
      page: () => const MenuPage(),
      binding: SideMenuBinding(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage<void>(
      name: AppRoutes.appSettings,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const AppSettingsPage(),
      binding: AppSettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.contact,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const ContactPage(),
      binding: ContactBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.training,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const TrainingPage(),
      binding: TrainingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage<void>(
      name: AppRoutes.trainingDetail,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const TrainingDetailPage(),
      binding: TrainingDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.skills,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const SkillsPage(),
      binding: SkillsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage<void>(
      name: AppRoutes.skillList,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const SkillListPage(),
      binding: SkillListBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.skillDetail,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const SkillDetailPage(),
      binding: SkillDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.trophyRoom,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const TrophyStorePage(),
      binding: TrophyStoreBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.trophyRoomDetail,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const TrophyDetailPage(),
      binding: TrophyDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.allTrophy,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const TrophyRoomPage(),
      binding: StatsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.coachTraining,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const CoachTrainingPage(),
      binding: CoachTrainingBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.coachTrainingDetail,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const CoachTrainingDetailPage(),
      binding: CoachTrainingDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: AppRoutes.coachInvitation,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const CoachInvitationPage(),
      binding: CoachInvitationBinding(),
      transition: Transition.cupertino,
    ),

    GetPage<void>(
      name: AppRoutes.ratingTracker,
      middlewares: <GetMiddleware>[AuthMiddleware()],
      page: () => const RatingTrackerPage(),
      binding: StatsBinding(),
      transition: Transition.cupertino,
    ),
    




    
  ];
}
