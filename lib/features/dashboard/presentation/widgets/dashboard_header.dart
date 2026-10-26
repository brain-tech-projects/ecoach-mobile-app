import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/menu_button.dart';

/// Fixed top bar: avatar + "Welcome / Login/SignUp" and the menu button.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.onProfileTap, this.onMenuTap});

  final VoidCallback onProfileTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return ColoredBox(
      color: AppColors.headerBg,
      child: Padding(
        padding: EdgeInsets.only(top: r.safeTop),
        child: SizedBox(
          height: 59 * s,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: onProfileTap,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 12 * s),
                            _Avatar(size: 36 * s),
                            SizedBox(width: 16 * s),
                            Padding(
                              padding: EdgeInsets.only(top: 6 * s),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Welcome',
                                    style: AppTextStyles.dashWelcome.scaled(s),
                                  ),
                                  Text(
                                    'Login/SignUp',
                                    style: AppTextStyles.dashName.scaled(s),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  MenuButton(scale: s, onTap: onMenuTap),
                  SizedBox(width: 12 * s),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.avatarBg,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: size * 0.72, color: AppColors.avatarFg),
    );
  }
}
