import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/menu/data/menu_items.dart';
import 'package:ecoach_pro/features/menu/domain/entities/menu_item.dart';
import 'package:ecoach_pro/features/menu/presentation/controllers/side_menu_controller.dart';

/// Signed-in side menu: close button, profile block with quick actions and
/// the list of sections (+ Logout). Signed-out users never get here (the
/// route is protected), they are sent to login instead.
class MenuPage extends GetView<SideMenuController> {
  const MenuPage({super.key});

  static String _firstName(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? full : parts.first;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    // Design coordinates assume no status bar; push down on notched phones.
    final topShift = math.max(0.0, r.safeTop - 20 * s);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: topShift,
          bottom: math.max(r.safeBottom, 24 * s),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 10 * s),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16 * s),
                    child: _CloseButton(scale: s, onTap: controller.close),
                  ),
                ),
                Obx(() {
                  final user = controller.session.user.value;
                  final loggedIn = controller.isLoggedIn && user != null;
                  final items = loggedIn ? MenuItems.all : MenuItems.forGuest;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: (loggedIn ? 24 : 40) * s),
                      if (loggedIn) ...<Widget>[
                        _ProfileBlock(
                          scale: s,
                          name: "${user!.fullName}",
                          photoUrl: user!.profilePhoto,
                          onEditPhoto: controller.openMyProfile,
                        ),
                        SizedBox(height: 14 * s),
                        _QuickActions(
                          scale: s,
                          unread: controller.unreadCount.value,
                          onStar: controller.openMySkills,
                          onEdit: controller.openNotes,
                          onChat: controller.openMessages,
                          onBell: controller.openNotifications,
                        ),
                        SizedBox(height: 40 * s),
                      ] else ...<Widget>[
                        _GuestProfileBlock(
                          scale: s,
                          onTap: controller.openLogin,
                        ),
                        SizedBox(height: 73.9 * s),
                      ],
                      for (final item in items)
                        _MenuRow(
                          item: item,
                          scale: s,
                          onTap: () => controller.openItem(item),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close menu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AppAssetIcon(
              AppAssets.menuClose,
              width: 24.67 * scale,
              height: 24.67 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

/// Signed-out profile block: tap to log in / sign up.
class _GuestProfileBlock extends StatelessWidget {
  const _GuestProfileBlock({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: 'Login or sign up',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            children: <Widget>[
              Container(
                width: 70 * s,
                height: 70 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.7 * s),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.avatarGradTop,
                      AppColors.avatarGradBottom,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 3.4 * s),
                    child: AppAssetIcon(
                      AppAssets.menuAvatarUser,
                      width: 30.3 * s,
                      height: 30.7 * s,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.9 * s),
              Text('Welcome', style: AppTextStyles.dashWelcome.scaled(s)),
              SizedBox(height: 8.4 * s),
              Text('Login/SignUp', style: AppTextStyles.dashName.scaled(s)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({
    required this.scale,
    required this.name,
    required this.onEditPhoto,
    this.photoUrl,
  });

  final double scale;
  final String name;
  final String? photoUrl;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final fallback = Center(
      child: AppAssetIcon(
        AppAssets.menuAvatarUser,
        width: 30.3 * s,
        height: 30.7 * s,
      ),
    );

    return Column(
      children: <Widget>[
        SizedBox(
          width: 74 * s,
          height: 74 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              GestureDetector(
                onTap: onEditPhoto,
                child: Container(
                width: 70 * s,
                height: 70 * s,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.7 * s),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.avatarGradTop,
                      AppColors.avatarGradBottom,
                    ],
                  ),
                ),
                child: (photoUrl == null || photoUrl!.isEmpty)
                    ? fallback
                    : Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => fallback,
                      ),
              ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onEditPhoto,
                  child: Container(
                    width: 22 * s,
                    height: 22 * s,
                    decoration: const BoxDecoration(
                      color: AppColors.selectGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 12 * s,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.9 * s),
        Text('Welcome', style: AppTextStyles.dashWelcome.scaled(s)),
        SizedBox(height: 8.4 * s),
        Text(name, style: AppTextStyles.dashName.scaled(s)),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.scale,
    required this.unread,
    required this.onStar,
    required this.onEdit,
    required this.onChat,
    required this.onBell,
  });

  final double scale;
  final int unread;
  final VoidCallback onStar;
  final VoidCallback onEdit;
  final VoidCallback onChat;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final gap = SizedBox(width: 8 * s);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _QuickTile(
          scale: s,
          icon: Icons.star_rounded,
          label: 'Rewards',
          onTap: onStar,
        ),
        gap,
        _QuickTile(
          scale: s,
          icon: Icons.edit_note_rounded,
          label: 'Edit profile',
          onTap: onEdit,
        ),
        gap,
        _QuickTile(
          scale: s,
          icon: Icons.forum_rounded,
          label: 'Messages',
          onTap: onChat,
        ),
        gap,
        _QuickTile(
          scale: s,
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
          badge: unread,
          onTap: onBell,
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.scale,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  final double scale;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final size = 40 * s;

    return Semantics(
      button: true,
      label: badge > 0 ? '$label, $badge unread' : label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(9 * s),
                ),
                child: Icon(icon, size: 20 * s, color: AppColors.selectGreen),
              ),
              if (badge > 0)
                Positioned(
                  right: -6 * s,
                  top: -6 * s,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 18 * s,
                      minHeight: 16 * s,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 9 * s,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.scale,
    required this.onTap,
  });

  final MenuItem item;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: item.label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 53.3 * s,
            child: Row(
              children: <Widget>[
                // 32 pt icon canvas centred 55.3 pt from the left edge.
                SizedBox(width: 39.3 * s),
                SizedBox(
                  width: 32 * s,
                  height: 32 * s,
                  child: item.iconAsset != null
                      ? AppAssetIcon(
                          item.iconAsset!,
                          width: 32 * s,
                          height: 32 * s,
                          color: AppColors.menuIcon,
                        )
                      : Icon(item.icon, size: 24 * s, color: AppColors.menuIcon),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Text(
                  // style: TextStyle(fontWeight: FontWeight.bold),
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.menuItem.scaled(s),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
