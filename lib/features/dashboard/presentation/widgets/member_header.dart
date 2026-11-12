import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/menu_button.dart';

/// Fixed top bar of the signed-in home: avatar, "Welcome <name>", menu
/// button and the notification bell with its unread badge.
class MemberHeader extends StatelessWidget {
  const MemberHeader({
    super.key,
    required this.name,
    required this.unreadCount,
    this.photoUrl,
    this.onMenuTap,
    this.onBellTap,
    this.onprofiletap,
  });

  final String name;
  final int unreadCount;
  final String? photoUrl;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;
  final VoidCallback? onprofiletap;

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
                  SizedBox(width: 12 * s),
                  _Avatar(size: 36 * s, url: photoUrl, onTap: onprofiletap,),
                  SizedBox(width: 16 * s),
                  Expanded(
                    child: Padding(
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.dashName.scaled(s),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MenuButton(scale: s, onTap: onMenuTap),
                  SizedBox(width: 8 * s),
                  _Bell(scale: s, count: unreadCount, onTap: onBellTap),
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
  const _Avatar({required this.size, this.url, this.onTap});

  final double size;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.person,
      size: size * 0.72,
      color: AppColors.avatarFg,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.avatarBg,
          shape: BoxShape.circle,
        ),
        child: (url == null || url!.isEmpty)
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell({required this.scale, required this.count, this.onTap});

  final double scale;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final label = count > 99 ? '99+' : '$count';

    return Semantics(
      button: true,
      label: 'Notifications, $count unread',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 36 * s,
          height: 36 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 36 * s,
                height: 36 * s,
                decoration: const BoxDecoration(
                  color: AppColors.menuCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  size: 20 * s,
                  color: AppColors.white,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -3 * s,
                  top: -3 * s,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 16 * s,
                      minHeight: 16 * s,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10 * s),
                    ),
                    child: Text(
                      label,
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
