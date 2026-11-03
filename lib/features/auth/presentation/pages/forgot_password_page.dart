import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    return AuthScaffold(
      onBack: () => Get.back<void>(),
      footer: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * s),
        child: AppPrimaryButton(
          label: 'Sign Up For Free',
          onPressed: controller.openSignUp,
          scale: s,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 120 * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 45.6 * s),
          Semantics(
            header: true,
            child: Text(
              'Forgot Your Password?',
              textAlign: TextAlign.center,
              style: AppTextStyles.otpTitle.scaled(s),
            ),
          ),
          SizedBox(height: 7 * s),
          Text(
            'Don’t worry! Resetting your password is easy. '
            'Just type in the email you registered.',
            textAlign: TextAlign.center,
            style: AppTextStyles.otpBody.scaled(s),
          ),
          SizedBox(height: 24 * s),
          AuthTextField(
            controller: controller.emailController,
            hint: 'Email address',
            iconAsset: AppAssets.iconMail,
            iconWidth: 19.3,
            iconHeight: 17.3,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.email],
            onChanged: controller.onEmailChanged,
            scale: s,
          ),
          Obx(() {
            final error = controller.emailError.value;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8 * s, left: 4 * s),
              child: Text(error, style: AppTextStyles.fieldError.scaled(s)),
            );
          }),
          SizedBox(height: 24 * s),
          Obx(
            () => AppPrimaryButton(
              label: 'Send',
              onPressed: controller.send,
              loading: controller.isLoading.value,
              scale: s,
            ),
          ),
        ],
      ),
    );
  }
}
