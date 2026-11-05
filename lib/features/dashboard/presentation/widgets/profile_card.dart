import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Photo, first name, role and country flag.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.scale,
    this.subtitle,
    this.photoUrl,
    this.flag,
  });

  final String name;
  final String? subtitle;
  final String? photoUrl;

  /// Flag emoji (built from the country code).
  final String? flag;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final photoFallback = Icon(
      Icons.person,
      size: 40 * s,
      color: AppColors.avatarFg,
    );

    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(11 * s),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 64 * s,
            height: 56 * s,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.avatarBg,
              borderRadius: BorderRadius.circular(8 * s),
              border: Border.all(color: AppColors.selectGreen, width: 1.5),
            ),
            child: (photoUrl == null || photoUrl!.isEmpty)
                ? photoFallback
                : Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => photoFallback,
                  ),
          ),
          SizedBox(width: 16 * s),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.programTitle.scaled(s),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(subtitle!, style: AppTextStyles.programDesc.scaled(s)),
              ],
            ),
          ),
          if (flag != null)
            // Container(
            //   width: 56 * s,
            //   height: 36 * s,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     color: AppColors.background,
            //     borderRadius: BorderRadius.circular(6 * s),
            //   ),
            //   child: Text(flag!, style: TextStyle(fontSize: 26 * s)),
          Text(flag!, style: TextStyle(fontSize: 50 * s)),
        ],
      ),
    );
  }
}
