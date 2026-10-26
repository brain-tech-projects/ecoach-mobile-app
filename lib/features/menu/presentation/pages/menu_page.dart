import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/menu/data/menu_items.dart';
import 'package:ecoach_pro/features/menu/presentation/controllers/side_menu_controller.dart';

/// Full-screen menu that slides in from the left (route transition) with a
/// close button, the profile block and the list of sections.
class MenuPage extends GetView<SideMenuController> {
  const MenuPage({super.key});

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
                SizedBox(height: 40 * s),
                _ProfileBlock(scale: s, onTap: controller.openLogin),
                SizedBox(height: 73.9 * s),
                for (final item in MenuItems.all)
                  _MenuRow(
                    label: item.label,
                    iconAsset: item.iconAsset,
                    scale: s,
                    onTap: () => controller.openItem(item),
                  ),
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

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.scale, required this.onTap});

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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.iconAsset,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 53.3 * s,
            child: Row(
              children: <Widget>[
                // 32 pt icon canvas centred 55.3 pt from the left edge.
                SizedBox(width: 39.3 * s),
                AppAssetIcon(
                  iconAsset,
                  width: 32 * s,
                  height: 32 * s,
                  color: AppColors.menuIcon,
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Text(
                    label,
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
