import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/features/auth/presentation/controllers/sign_up_controller.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/country_picker.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/form_field_block.dart';

/// Last screen: email, profile name, password, country (+ privacy note for
/// player / parent). Coaches get the same form with "Coach" labels.
class AccountStep extends StatelessWidget {
  const AccountStep({
    super.key,
    required this.controller,
    required this.isCoach,
    required this.scale,
  });

  final SignUpController controller;
  final bool isCoach;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final c = controller;
    final gap = SizedBox(height: 16.5 * s);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Obx(
          () => FormFieldBlock(
            label: isCoach ? 'Coach Email *' : 'Parent/Guardian Email *',
            controller: c.emailController,
            hint: 'your.email@example.com',
            iconAsset: AppAssets.iconMail,
            iconWidth: 19.3,
            iconHeight: 17.3,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[AutofillHints.email],
            errorText: c.emailError.value,
            isValid: c.isEmailValid,
            onChanged: c.onEmailChanged,
            scale: s,
          ),
        ),
        gap,
        Obx(
          () => FormFieldBlock(
            label: isCoach ? 'Coach Profile Name *' : 'Player Profile Name *',
            controller: c.nameController,
            hint: 'eg. John Smith',
            iconAsset: AppAssets.iconUser,
            iconWidth: 15.7,
            iconHeight: 19.3,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            errorText: c.nameError.value,
            isValid: c.isNameValid,
            onChanged: c.onNameChanged,
            scale: s,
          ),
        ),
        gap,
        Obx(
          () => FormFieldBlock(
            label: 'Password',
            controller: c.passwordController,
            hint: '*****',
            iconAsset: AppAssets.iconLock,
            iconWidth: 15.7,
            iconHeight: 18.7,
            obscureText: c.obscurePassword.value,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.newPassword],
            errorText: c.passwordError.value,
            isValid: c.isPasswordValid,
            onChanged: c.onPasswordChanged,
            scale: s,
            suffix: InkResponse(
              onTap: c.togglePasswordVisibility,
              child: Center(
                child: c.obscurePassword.value
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
        SizedBox(height: 16.8 * s),
        Text('Country', style: AppTextStyles.fieldLabel.scaled(s)),
        SizedBox(height: 5.5 * s),
        Obx(
          () => CountryField(
            country: c.country.value,
            scale: s,
            onTap: () async {
              final picked = await CountryPickerSheet.show(
                context,
                selected: c.country.value,
                scale: s,
              );
              if (picked != null) c.selectCountry(picked);
            },
          ),
        ),
        if (!isCoach) ...<Widget>[
          SizedBox(height: 16.2 * s),
          _PrivacyNote(scale: s),
        ],
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 3 * s),
        Padding(
          padding: EdgeInsets.only(top: 6.1 * s),
          child: AppAssetIcon(
            AppAssets.iconLock,
            width: 10 * s,
            height: 13.3 * s,
          ),
        ),
        SizedBox(width: 11 * s),
        Expanded(
          child: Text(
            'We\'ll use this to save your personalised programme and keep '
            'you updated.',
            style: AppTextStyles.noteText.scaled(s),
          ),
        ),
      ],
    );
  }
}
