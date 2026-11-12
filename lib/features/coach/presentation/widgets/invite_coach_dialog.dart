import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// "Invite your coach": email field + Cancel / Send.
class InviteCoachDialog extends StatefulWidget {
  const InviteCoachDialog({super.key, required this.onSend});

  /// Returns true when the invitation was sent (the dialog then closes).
  final Future<bool> Function(String email) onSend;

  @override
  State<InviteCoachDialog> createState() => _InviteCoachDialogState();
}

class _InviteCoachDialogState extends State<InviteCoachDialog> {
  final TextEditingController _email = TextEditingController();
  bool _busy = false;

  Future<void> _send() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.onSend(_email.text);
    if (!mounted) return;
    if (ok) {
      Get.back<void>();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    Widget action(String label, Color color, VoidCallback onTap) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 9 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * s),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: AppTextStyles.dialogBody.scaled(s).copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );

    return Dialog(
      backgroundColor: AppColors.dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 19 * s, vertical: 24 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * s)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * s, 24 * s, 20 * s, 20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: Text('Invite a Coach', style: AppTextStyles.dialogTitle.scaled(s))),
            SizedBox(height: 8 * s),
            Text(
              'Enter your coach\'s email address. If they\'re already registered, they\'ll receive an invitation to connect. If not, they\'ll get an email with a link to sign up.',
              style: AppTextStyles.dialogBody.scaled(s),
            ),
            SizedBox(height: 16 * s),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: AppTextStyles.dialogBody.scaled(s).copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'coach@example.com',
                hintStyle: AppTextStyles.dialogBody.scaled(s).copyWith(color: AppColors.hint),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: EdgeInsets.all(14 * s),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                  borderSide: const BorderSide(color: AppColors.selectGreen),
                ),
              ),
            ),
            SizedBox(height: 20 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                action('Cancel', AppColors.selectGreen, () => Get.back<void>()),
                SizedBox(width: 10 * s),
                action(_busy ? '...' : 'Send Invitation', AppColors.white, _send),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
