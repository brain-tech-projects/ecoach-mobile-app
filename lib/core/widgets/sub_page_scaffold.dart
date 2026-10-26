import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_bottom_nav.dart';
import 'package:ecoach_pro/core/widgets/menu_button.dart';

/// Frame for inner pages (App Settings, Contact us ...): grey header with a
/// back arrow, centred title and menu button; a rounded dark panel for the
/// [body]; and the floating bottom tab bar (hidden while the keyboard is up).
class SubPageScaffold extends StatelessWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.navIndex = -1,
    this.floatingAction,
  });

  final String title;
  final Widget body;

  /// Highlighted tab (-1 = none).
  final int navIndex;
  final Widget? floatingAction;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final navBottom = math.max(8.7 * s, r.safeBottom);
    final navSpace = keyboardOpen
        ? 0.0
        : AppBottomNav.designHeight * s + navBottom + 8 * s;

    return Scaffold(
      backgroundColor: AppColors.headerBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: <Widget>[
              _Header(title: title, safeTop: r.safeTop, scale: s),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(21 * s),
                  ),
                  child: ColoredBox(
                    color: AppColors.background,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: navSpace),
                      child: body,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!keyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: navBottom,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1 * s),
                    child: AppBottomNav(
                      currentIndex: navIndex,
                      onTap: MainNav.onTabSelected,
                      scale: s,
                    ),
                  ),
                ),
              ),
            ),
          if (!keyboardOpen && floatingAction != null)
            Positioned(
              right: r.gutter + 24 * s,
              bottom: navBottom + AppBottomNav.designHeight * s + 10 * s,
              child: floatingAction!,
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.safeTop,
    required this.scale,
  });

  final String title;
  final double safeTop;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return ColoredBox(
      color: AppColors.headerBg,
      child: Padding(
        padding: EdgeInsets.only(top: safeTop),
        child: SizedBox(
          height: 51.7 * s,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Padding(
                  // Title is centred between the arrow and the menu button.
                  padding: EdgeInsets.only(left: 32.7 * s, right: 48 * s),
                  child: Center(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.pageTitle.scaled(s),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 2.2 * s,
                top: (51.7 * s - 44) / 2,
                child: IconButton(
                  onPressed: () => Get.back<void>(),
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  iconSize: 25 * s,
                  color: AppColors.white,
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              Positioned(
                right: 12 * s,
                top: 7.85 * s,
                child: MenuButton(scale: s, onTap: MainNav.openMenu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
