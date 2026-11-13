import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// Chat + bell shortcuts under the coach's name in the side menu.
class CoachMenuActions extends StatelessWidget {
  const CoachMenuActions({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    Widget tile(IconData icon, String label, String route) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () => Get.offNamed<void>(route),
        child: Container(
          width: 40 * s,
          height: 40 * s,
          decoration: BoxDecoration(color: const Color(0xFF1B3A2E), borderRadius: BorderRadius.circular(14 * s)),
          child: Icon(icon, color: AppColors.accent, size: 22 * s),
        ),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        tile(Icons.forum_rounded, 'Chats', AppRoutes.coachChats),
        SizedBox(width: 16 * s),
        tile(Icons.notifications_none_rounded, 'Notifications', AppRoutes.notifications),
      ],
    );
  }
}
