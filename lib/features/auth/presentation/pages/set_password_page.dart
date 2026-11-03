import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/set_password_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';

class SetPasswordPage extends GetView<SetPasswordController> {
  const SetPasswordPage({super.key});

  Widget _eye(double s, bool obscured, VoidCallback onTap) => InkResponse(
    onTap: onTap,
    child: Center(
      child: obscured
          ? AppAssetIcon(
              AppAssets.iconEyeOff,
              width: 24 * s,
              height: 22 * s,
              color: AppColors.hint,
            )
          : Icon(Icons.visibility_outlined, size: 24 * s, color: AppColors.hint),
    ),
  );

  Widget _error(String? text, double s) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: EdgeInsets.only(top: 8 * s, left: 4 * s),
          child: Text(text, style: AppTextStyles.fieldError.scaled(s)),
        );

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
              'Set a New Password',
              textAlign: TextAlign.center,
              style: AppTextStyles.otpTitle.scaled(s),
            ),
          ),
          SizedBox(height: 7 * s),
          Text(
            'Your email has been successfully verified. '
            'Now create your new password to access your account.',
            textAlign: TextAlign.center,
            style: AppTextStyles.otpBody.scaled(s),
          ),
          SizedBox(height: 24 * s),
          Obx(
            () => AuthTextField(
              controller: controller.passwordController,
              hint: 'Enter New Password',
              iconAsset: AppAssets.iconLock,
              iconWidth: 15.7,
              iconHeight: 18.7,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              onChanged: controller.onPasswordChanged,
              scale: s,
              suffix: _eye(
                s,
                controller.obscurePassword.value,
                controller.togglePassword,
              ),
            ),
          ),
          Obx(() => _error(controller.passwordError.value, s)),
          SizedBox(height: 16.7 * s),
          Obx(
            () => AuthTextField(
              controller: controller.confirmController,
              hint: 'Enter Confirm Password',
              iconAsset: AppAssets.iconLock,
              iconWidth: 15.7,
              iconHeight: 18.7,
              obscureText: controller.obscureConfirm.value,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.newPassword],
              onChanged: controller.onConfirmChanged,
              scale: s,
              suffix: _eye(
                s,
                controller.obscureConfirm.value,
                controller.toggleConfirm,
              ),
            ),
          ),
          Obx(() => _error(controller.confirmError.value, s)),
          SizedBox(height: 24 * s),
          Obx(
            () => AppPrimaryButton(
              label: 'Submit',
              onPressed: controller.submit,
              loading: controller.isLoading.value,
              scale: s,
            ),
          ),
        ],
      ),
    );
  }
}
