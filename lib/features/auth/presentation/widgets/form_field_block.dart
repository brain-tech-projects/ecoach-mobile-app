import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';

/// Label + input + optional red error. The border is green once the value is
/// valid, grey otherwise (also grey while an error is showing).
class FormFieldBlock extends StatelessWidget {
  const FormFieldBlock({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.isValid,
    required this.scale,
    this.errorText,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final bool isValid;
  final double scale;
  final String? errorText;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.fieldLabel.scaled(s)),
        SizedBox(height: 5.8 * s),
        AuthTextField(
          controller: controller,
          hint: hint,
          iconAsset: iconAsset,
          iconWidth: iconWidth,
          iconHeight: iconHeight,
          obscureText: obscureText,
          suffix: suffix,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          borderColor: (!hasError && isValid)
              ? AppColors.accent
              : AppColors.fieldBorder,
          scale: s,
        ),
        if (hasError)
          Text(errorText!, style: AppTextStyles.fieldError.scaled(s)),
      ],
    );
  }
}
