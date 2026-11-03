import 'package:flutter/material.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/menu/domain/entities/menu_item.dart';

/// Signed-in side menu, top to bottom. Items with an empty route show
/// "Coming soon" until their page exists - just fill in the route.
abstract final class MenuItems {
  static const List<MenuItem> all = <MenuItem>[
    MenuItem(
      label: 'Install App',
      icon: Icons.install_mobile_outlined,
      action: MenuAction.installApp,
    ),
    MenuItem(
      label: 'Personal Training Session',
      iconAsset: AppAssets.menuPersonal,
      route: AppRoutes.training,
    ),
    MenuItem(
      label: 'AI Training Session',
      iconAsset: AppAssets.menuPersonal,
    ),
    MenuItem(
      label: 'My Skills',
      iconAsset: AppAssets.menuSkills,
      route: AppRoutes.skills,
    ),
    MenuItem(
      label: 'Coaches Training',
      iconAsset: AppAssets.menuCoaches,
      route: AppRoutes.coachTraining,
    ),
    MenuItem(
      label: 'Trophy Room',
      iconAsset: AppAssets.menuTrophy,
      route: AppRoutes.trophyRoom,
    ),
    MenuItem(
      label: 'Subscription Options',
      iconAsset: AppAssets.menuSubscription,
      route: AppRoutes.subscription,
    ),
    MenuItem(
      label: 'Coach Invitation',
      iconAsset: AppAssets.menuInvitation,
      route: AppRoutes.coachInvitation,
    ),
    MenuItem(
      label: 'App Settings',
      iconAsset: AppAssets.menuSettings,
      route: AppRoutes.appSettings,
    ),
    MenuItem(
      label: 'Contact Us',
      iconAsset: AppAssets.menuContact,
      route: AppRoutes.contact,
    ),
    MenuItem(
      label: 'Logout',
      icon: Icons.logout,
      action: MenuAction.logout,
    ),
  ];

  /// Signed-out menu: same list without Logout.
  static List<MenuItem> get forGuest =>
      all.where((item) => item.action != MenuAction.logout).toList();
}
