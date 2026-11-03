import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/otp_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/otp_input.dart';

/// 6-digit code screen, two flavours (see `OtpPurpose`):
///  * sign-up: verify the parent / guardian email (players aged 5-12)
///  * reset password: "Verify Email" step of Forgot Password
class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final isReset = controller.isReset;
    final bold = AppTextStyles.otpBody
        .scaled(s)
        .copyWith(fontWeight: FontWeight.w600);

    final resendRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          isReset ? 'Didn’t receive code?' : 'Didn’t receive a code?',
          style: AppTextStyles.footerText.scaled(s),
        ),
        SizedBox(width: 9 * s),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.resend,
          child: Text(
            isReset ? 'Resend' : 'Resend Code',
            style: AppTextStyles.footerLink
                .scaled(s)
                .copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );

    return AuthScaffold(
      onBack: () => Get.back<void>(),
      footer: isReset
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: AppPrimaryButton(
                label: 'Sign Up For Free',
                onPressed: () => Get.offNamed<void>(AppRoutes.signUp),
                scale: s,
              ),
            )
          : resendRow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: (isReset ? 120 : 49) * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 45.6 * s),
          Semantics(
            header: true,
            child: Text(
              isReset ? 'Verify Email' : 'OTP Verification',
              textAlign: TextAlign.center,
              style: AppTextStyles.otpTitle.scaled(s),
            ),
          ),
          SizedBox(height: 7 * s),
          Text(
            isReset
                ? 'We\'ve sent a 6-digit verification code to'
                : 'We\'ve sent a 6-digit verification code to your '
                      'parent/guardian\'s email.',
            textAlign: TextAlign.center,
            style: AppTextStyles.otpBody.scaled(s),
          ),
          SizedBox(height: 4.6 * s),
          if (isReset)
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: controller.email, style: bold),
                  const TextSpan(text: '  '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.changeEmail,
                      child: Text(
                        'Change',
                        style: AppTextStyles.otpEmail
                            .scaled(s)
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.otpBody.scaled(s),
            )
          else
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
                const TextSpan(
                  text: ' If you don\'t see the email, please check the ',
                ),
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
          Obx(
            () => AppPrimaryButton(
              label: isReset ? 'Done' : 'Verify Email',
              onPressed: controller.verify,
              loading: controller.isLoading.value,
              scale: s,
            ),
          ),
          if (isReset) ...<Widget>[
            SizedBox(height: 20 * s),
            resendRow,
          ],
        ],
      ),
    );
  }
}
