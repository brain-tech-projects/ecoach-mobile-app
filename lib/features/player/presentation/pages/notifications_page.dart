import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/notifications_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/notification_card.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Notifications',
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        if (controller.errorMessage.value != null) {
          return RetryMessage(
            message: controller.errorMessage.value!,
            onRetry: controller.load,
            scale: s,
          );
        }
        final blocked = controller.permissionBlocked.value;
        final items = controller.items;

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 24 * s),
            children: <Widget>[
              if (blocked) ...<Widget>[
                _BlockedBanner(scale: s, onDismiss: controller.dismissBanner),
                SizedBox(height: 16.7 * s),
              ],
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 12 * s),
                  child: Center(
                    child: Text('No notifications yet.', style: AppTextStyles.programDesc.scaled(s)),
                  ),
                )
              else
                for (var i = 0; i < items.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 8.3 * s),
                  NotificationCard(item: items[i], scale: s),
                ],
            ],
          ),
        );
      }),
    );
  }
}

class _BlockedBanner extends StatelessWidget {
  const _BlockedBanner({required this.scale, required this.onDismiss});

  final double scale;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.fromLTRB(17 * s, 17 * s, 17 * s, 14 * s),
      decoration: BoxDecoration(
        color: const Color(0xFF1C343F),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Notifications are blocked. Enable notifications for eCoach in your '
            'device settings to get updates.',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16 * s,
              height: 1.3,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20 * s),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16 * s,
                  color: AppColors.descGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
