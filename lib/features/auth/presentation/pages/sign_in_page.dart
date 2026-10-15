import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    return AuthScaffold(
      onBack: () => Get.back<void>(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 180 * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 71 * s),
          AuthTextField(
            controller: controller.emailController,
            hint: 'abc@email.com',
            iconAsset: AppAssets.iconMail,
            iconWidth: 19.3,
            iconHeight: 17.3,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            scale: s,
          ),
          SizedBox(height: 16.7 * s),
          Obx(
            () => AuthTextField(
              controller: controller.passwordController,
              hint: 'Your password',
              iconAsset: AppAssets.iconLock,
              iconWidth: 15.7,
              iconHeight: 18.7,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              scale: s,
              suffix: InkResponse(
                onTap: controller.togglePasswordVisibility,
                child: Center(
                  child: controller.obscurePassword.value
                      ? AppAssetIcon(
                          AppAssets.iconEyeOff,
                          width: 24 * s,
                          height: 22 * s,
                          color: AppColors.hint,
                        )
                      : Icon(
                          Icons.visibility_outlined,
                          size: 24 * s,
                          color: AppColors.hint,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.9 * s),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.link.scaled(s),
            ),
          ),
          SizedBox(height: 24.5 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.3 * s),
            child: AppPrimaryButton(
              label: 'Sign in',
              onPressed: controller.signIn,
              scale: s,
            ),
          ),
          SizedBox(height: 16 * s),
          AppPrimaryButton(
            label: 'Sign Up For Free',
            onPressed: controller.openSignUp,
            scale: s,
          ),
        ],
      ),
    );
  }
}
