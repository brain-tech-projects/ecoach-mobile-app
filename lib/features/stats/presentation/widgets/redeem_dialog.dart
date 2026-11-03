import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// "Redeem Item" confirmation. [onRedeem] returns true when the trophy was
/// redeemed (dialog closes); false keeps the dialog open (an error toast is
/// shown by the caller). Buttons are locked while the request runs.
class RedeemDialog extends StatefulWidget {
  const RedeemDialog({super.key, required this.onRedeem});

  final Future<bool> Function() onRedeem;

  @override
  State<RedeemDialog> createState() => _RedeemDialogState();
}

class _RedeemDialogState extends State<RedeemDialog> {
  bool _busy = false;

  Future<void> _redeem() async {
    if (_busy) return;
    setState(() => _busy = true);
    final done = await widget.onRedeem();
    if (!mounted) return;
    if (done) {
      Get.back<void>();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    return Dialog(
      backgroundColor: AppColors.dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 19 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23 * s)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 355 * s),
        child: Padding(
          padding: EdgeInsets.fromLTRB(26 * s, 24 * s, 26 * s, 26 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text('Redeem Item', style: AppTextStyles.dialogTitle.scaled(s)),
              ),
              SizedBox(height: 15 * s),
              Text(
                'By clicking redeem, you are confirming that the reward has '
                'been received and the corresponding points will, therefore, '
                'be deducted from your account.',
                style: AppTextStyles.dialogBody.scaled(s * 14 / 16),
              ),
              SizedBox(height: 21 * s),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _DialogButton(
                    label: 'Cancel',
                    width: 87 * s,
                    filled: false,
                    scale: s,
                    onTap: _busy ? null : () => Get.back<void>(),
                  ),
                  SizedBox(width: 8 * s),
                  _DialogButton(
                    label: 'Redeem',
                    width: 97 * s,
                    filled: true,
                    busy: _busy,
                    scale: s,
                    onTap: _busy ? null : _redeem,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.width,
    required this.filled,
    required this.scale,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final double width;
  final bool filled;
  final bool busy;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12 * scale);
    final color = filled ? AppColors.black : AppColors.accent;

    return Material(
      color: filled ? AppColors.accent : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: 31 * scale,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 16 * scale,
                    height: 16 * scale,
                    child: CircularProgressIndicator(strokeWidth: 2, color: color),
                  )
                : Text(
                    label,
                    style: AppTextStyles.dialogButton.scaled(scale).copyWith(color: color),
                  ),
          ),
        ),
      ),
    );
  }
}
