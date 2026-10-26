import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// "Great Work!" confirmation. Pops `true` on Confirm, `false` on Cancel.
class CompleteDialog extends StatelessWidget {
  const CompleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    return Dialog(
      backgroundColor: AppColors.dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 19 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * s)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(26 * s, 26.5 * s, 26 * s, 26 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text('Great Work!', style: AppTextStyles.dialogTitle.scaled(s)),
            ),
            SizedBox(height: 15.5 * s),
            Text(
              'Confirm you have completed this skill. Keep practising each '
              'skill and increase your eCoach stats.',
              style: AppTextStyles.dialogBody.scaled(s),
            ),
            SizedBox(height: 20.3 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _DialogButton(
                  label: 'Cancel',
                  width: 89 * s,
                  height: 30.7 * s,
                  filled: false,
                  scale: s,
                  onTap: () => Get.back<bool>(result: false),
                ),
                SizedBox(width: 8.3 * s),
                _DialogButton(
                  label: 'Confirm',
                  width: 95 * s,
                  height: 30.7 * s,
                  filled: true,
                  scale: s,
                  onTap: () => Get.back<bool>(result: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.width,
    required this.height,
    required this.filled,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double width;
  final double height;
  final bool filled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10 * scale);

    return Material(
      color: filled ? AppColors.accent : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled ? BorderSide.none : const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.dialogButton
                  .scaled(scale)
                  .copyWith(color: filled ? AppColors.black : AppColors.accent),
            ),
          ),
        ),
      ),
    );
  }
}
