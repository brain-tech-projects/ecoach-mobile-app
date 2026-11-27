import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/training/presentation/controllers/training_complete_controller.dart';

/// "Training Complete": confirm the video is done to unlock the next one.
class TrainingCompletePage extends GetView<TrainingCompleteController> {
  const TrainingCompletePage({super.key});

  static const Color _red = Color(0xFFE9736E);

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    TextStyle text(double size, FontWeight w, Color c, {double? spacing, double? height}) =>
        TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: size * s,
          fontWeight: w,
          color: c,
          letterSpacing: spacing,
          height: height,
        );

    return SubPageScaffold(
      title: 'Training Complete',
      navIndex: MainNav.trainingIndex,
      body: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 24 * s),
        child: Column(
          children: <Widget>[
            Obx(() {
              final next = controller.nextTitle.value;
              if (next == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 20 * s),
                child: Row(
                  children: <Widget>[
                    Container(width: 16 * s, height: 2 * s, color: AppColors.accent),
                    SizedBox(width: 14 * s),
                    Flexible(
                      child: Text(
                        'NEXT UP: ${next.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: text(20, FontWeight.w700, AppColors.white, spacing: 1.2),
                      ),
                    ),
                    SizedBox(width: 14 * s),
                    Container(width: 16 * s, height: 2 * s, color: AppColors.accent),
                  ],
                ),
              );
            }),
            Text(
              'Have you completed this training?',
              textAlign: TextAlign.center,
              style: text(17, FontWeight.w600, AppColors.white),
            ),
            SizedBox(height: 8 * s),
            Text(
              'Ready to unlock your next\ntraining session?',
              textAlign: TextAlign.center,
              style: text(19, FontWeight.w400, AppColors.descGrey, height: 1.35),
            ),
            SizedBox(height: 44 * s),
            Obx(
              () => _Option(
                label: "Yes, let's do it!",
                icon: Icons.check,
                iconColor: AppColors.accent,
                selected: controller.completed.value,
                scale: s,
                onTap: () => controller.select(yes: true),
              ),
            ),
            SizedBox(height: 12 * s),
            Obx(
              () => _Option(
                label: "Not yet, I'd like to do my current training again",
                icon: Icons.close,
                iconColor: _red,
                selected: !controller.completed.value,
                scale: s,
                onTap: () => controller.select(yes: false),
              ),
            ),
            const Spacer(),
            Obx(
              () => SizedBox(
                width: 225 * s,
                height: 40 * s,
                child: Material(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12 * s),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12 * s),
                    onTap: controller.isSubmitting.value ? null : () => _onOkay(context),
                    child: Center(
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 18 * s,
                              height: 18 * s,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text('Okay', style: text(17, FontWeight.w600, Colors.black)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onOkay(BuildContext context) async {
    // "Not yet": nothing to save, just go back.
    if (!controller.completed.value) {
      Get.back<void>();
      return;
    }
    final result = await controller.submit();
    if (!result.done || !context.mounted) return;
    await Get.dialog<void>(
      _AllSetDialog(availableIn: result.availableIn, scale: Responsive.of(context).scale),
    );
    // Back to the level; it reloads to show the next video's countdown.
    Get.back<bool>(result: true);
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 48 * s),
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF446A58) : AppColors.card,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: selected ? AppColors.accent : AppColors.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 24 * s,
                height: 24 * s,
                decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                child: Icon(icon, size: 14 * s, color: const Color(0xFF14262F)),
              ),
              SizedBox(width: 14 * s),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15 * s,
                    color: AppColors.white,
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

/// "You're all set!" popup after confirming.
class _AllSetDialog extends StatelessWidget {
  const _AllSetDialog({required this.availableIn, required this.scale});

  /// Backend's `available_in` ("2 days"); null = unlocked now.
  final String? availableIn;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final wait = availableIn;
    final unlockedNow = wait == null || RegExp(r'^0+(\D|$)').hasMatch(wait);
    final message = unlockedNow
        ? 'Your next training session is now unlocked.'
        : 'Your next training session will be unlocked in $wait.';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 18 * s),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30 * s),
            padding: EdgeInsets.fromLTRB(24 * s, 50 * s, 24 * s, 26 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF173A4A),
              borderRadius: BorderRadius.circular(24 * s),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'You’re all set!',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 21 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 10 * s),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16 * s,
                    height: 1.4,
                    color: const Color(0xFFD5DDE0),
                  ),
                ),
                SizedBox(height: 26 * s),
                SizedBox(
                  height: 38 * s,
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10 * s),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10 * s),
                      onTap: () => Get.back<void>(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32 * s),
                        child: Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 15 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60 * s,
            height: 60 * s,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3 * s),
            ),
            child: Icon(Icons.emoji_events_outlined, size: 30 * s, color: const Color(0xFF14262F)),
          ),
        ],
      ),
    );
  }
}
