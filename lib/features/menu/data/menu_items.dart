import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/menu/domain/entities/menu_item.dart';

/// Side-menu sections, top to bottom. Everything except App Settings and
/// Contact Us needs an account, so it opens login / sign-up for now.
abstract final class MenuItems {
  static const List<MenuItem> all = <MenuItem>[
    MenuItem(
      label: 'Personal Training Session',
      iconAsset: AppAssets.menuPersonal,
      route: AppRoutes.signIn,
    ),
    MenuItem(
      label: 'My Skills',
      iconAsset: AppAssets.menuSkills,
      route: AppRoutes.signIn,
    ),
    MenuItem(
      label: 'Coaches Training',
      iconAsset: AppAssets.menuCoaches,
      route: AppRoutes.signIn,
    ),
    MenuItem(
      label: 'Trophy Room',
      iconAsset: AppAssets.menuTrophy,
      route: AppRoutes.trophyRoom,
    ),
    MenuItem(
      label: 'Subscription Options',
      iconAsset: AppAssets.menuSubscription,
      route: AppRoutes.signIn,
    ),
    MenuItem(
      label: 'Coach Invitation',
      iconAsset: AppAssets.menuInvitation,
      route: AppRoutes.signIn,
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
  ];
}
