import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/features/auth/data/signup_content.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/account_step.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/age_grid.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/choice_option_card.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/role_option_card.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/step_progress_bar.dart';

/// The whole sign-up flow in one page: the logo and progress bar stay put
/// while the step content changes (role -> age -> ... -> account).
class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    final scaffold = AuthScaffold(
      onBack: controller.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 32.7 * s),
          Center(child: AppLogoHorizontal(scale: s)),
          SizedBox(height: 31 * s),
          Obx(
            () => StepProgressBar(
              step: controller.stepNumber,
              total: controller.totalSteps,
              scale: s,
            ),
          ),
          SizedBox(height: 36.3 * s),
          Obx(() => _buildStep(s)),
        ],
      ),
    );

    // System back / swipe-back goes to the previous step first.
    return Obx(
      () => PopScope(
        canPop: controller.stepIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.onBack();
        },
        child: scaffold,
      ),
    );
  }

  Widget _buildStep(double s) {
    final kind = controller.currentKind;
    final role = controller.selectedRole.value;
    final header = SignUpContent.headerFor(kind, role);
    final isRole = kind == SignUpStepKind.role;
    final isAccount = kind == SignUpStepKind.account;
    final label = isAccount
        ? (controller.isCoach ? 'Sign Up' : 'Create My Programme')
        : 'Next';
    final afterContent = isAccount && !controller.isCoach ? 25.5 : 24.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey<SignUpStepKind>(kind),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  header.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.authTitle.scaled(s),
                ),
              ),
              SizedBox(height: 2 * s),
              Text(
                header.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.authSubtitle.scaled(s),
              ),
              SizedBox(height: 24.7 * s),
              _buildContent(kind, s),
              SizedBox(height: afterContent * s),
            ],
          ),
        ),
        AppPrimaryButton(
          label: label,
          enabled: controller.canProceed,
          onPressed: controller.onNext,
          scale: s,
        ),
        if (isRole) ...<Widget>[
          SizedBox(height: 56.3 * s),
          AppPrimaryButton(
            label: 'Have an account ? Sign In',
            onPressed: controller.openSignIn,
            scale: s,
            labelStyle: AppTextStyles.buttonLabelSmall,
          ),
        ],
      ],
    );
  }

  Widget _buildContent(SignUpStepKind kind, double s) {
    switch (kind) {
      case SignUpStepKind.role:
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

      case SignUpStepKind.age:
        return AgeGrid(
          options: SignUpContent.ageOptions,
          selectedId: controller.selected(kind).firstOrNull,
          onSelected: (o) => controller.select(kind, o.id, multiple: false),
          scale: s,
        );

      case SignUpStepKind.account:
        return AccountStep(
          controller: controller,
          isCoach: controller.isCoach,
          scale: s,
        );

      case SignUpStepKind.positions:
      case SignUpStepKind.level:
      case SignUpStepKind.improve:
      case SignUpStepKind.difference:
      case SignUpStepKind.frequency:
        final question = SignUpContent.questionFor(kind)!;
        return Column(
          children: <Widget>[
            for (final option in question.options) ...<Widget>[
              if (option != question.options.first) SizedBox(height: 8.3 * s),
              ChoiceOptionCard(
                option: option,
                selected: controller.isSelected(kind, option.id),
                multiple: question.multiple,
                onTap: () => controller.select(
                  kind,
                  option.id,
                  multiple: question.multiple,
                ),
                scale: s,
              ),
            ],
          ],
        );
    }
  }
}
