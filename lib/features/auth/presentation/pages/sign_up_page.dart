import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/role_option_card.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/step_progress_bar.dart';

/// Sign-up step 1: "Who is this for?" (player / coach / parent).
class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    return AuthScaffold(
      onBack: () => Get.back<void>(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 32.7 * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 31 * s),
          Obx(
            () => StepProgressBar(
              step: controller.currentStep,
              total: controller.selectedRole.value.totalSteps,
              scale: s,
            ),
          ),
          SizedBox(height: 35 * s),
          Semantics(
            header: true,
            child: Text(
              'Who is this for?',
              textAlign: TextAlign.center,
              style: AppTextStyles.authTitle.scaled(s),
            ),
          ),
          Text(
            'This helps us create the right experience for you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.authSubtitle.scaled(s),
          ),
          SizedBox(height: 24.7 * s),
          Obx(() {
            final selected = controller.selectedRole.value;
            return Column(
              children: <Widget>[
                for (final role in UserRole.values) ...<Widget>[
                  if (role != UserRole.values.first) SizedBox(height: 16.3 * s),
                  RoleOptionCard(
                    role: role,
                    selected: role == selected,
                    onTap: () => controller.selectRole(role),
                    scale: s,
                  ),
                ],
              ],
            );
          }),
          SizedBox(height: 24.3 * s),
          AppPrimaryButton(
            label: 'Next',
            onPressed: controller.onNext,
            scale: s,
          ),
          SizedBox(height: 56.3 * s),
          AppPrimaryButton(
            label: 'Have an account ? Sign In',
            onPressed: controller.openSignIn,
            scale: s,
            labelStyle: AppTextStyles.buttonLabelSmall,
          ),
        ],
      ),
    );
  }
}
