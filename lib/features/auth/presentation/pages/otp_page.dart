import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/otp_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/otp_input.dart';

/// Shown after sign-up for players aged 5-12: verify the parent / guardian's
/// email with a 6-digit code.
class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final bold = AppTextStyles.otpBody
        .scaled(s)
        .copyWith(fontWeight: FontWeight.w600);

    return AuthScaffold(
      onBack: () => Get.back<void>(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Didn’t receive a code?',
            style: AppTextStyles.footerText.scaled(s),
          ),
          SizedBox(width: 9 * s),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.resend,
            child: Text('Resend Code', style: AppTextStyles.footerLink.scaled(s)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 49 * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 45.6 * s),
          Semantics(
            header: true,
            child: Text(
              'OTP Verification',
              textAlign: TextAlign.center,
              style: AppTextStyles.otpTitle.scaled(s),
            ),
          ),
          SizedBox(height: 7 * s),
          Text(
            'We\'ve sent a 6-digit verification code to your '
            'parent/guardian\'s email.',
            textAlign: TextAlign.center,
            style: AppTextStyles.otpBody.scaled(s),
          ),
          SizedBox(height: 4.6 * s),
          Text(
            controller.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.otpEmail.scaled(s),
          ),
          SizedBox(height: 4 * s),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'Note:', style: bold),
                const TextSpan(text: ' If you don\'t see the email, please check the '),
                TextSpan(text: 'Spam/Junk', style: bold),
                const TextSpan(text: ' folder.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.otpBody.scaled(s),
          ),
          SizedBox(height: 24.7 * s),
          Center(
            child: OtpInput(
              controller: controller.codeController,
              focusNode: controller.focusNode,
              length: OtpController.codeLength,
              onChanged: controller.onChanged,
              scale: s,
            ),
          ),
          Obx(() {
            final error = controller.error.value;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8 * s),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: AppTextStyles.fieldError.scaled(s),
              ),
            );
          }),
          SizedBox(height: 48.4 * s),
          AppPrimaryButton(
            label: 'Verify Email',
            onPressed: controller.verify,
            scale: s,
          ),
        ],
      ),
    );
  }
}
