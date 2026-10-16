import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';

/// Rounded input with a leading icon and an optional trailing widget
/// (e.g. the show/hide-password toggle).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.suffix,
    this.borderColor = AppColors.fieldBorder,
    this.onChanged,
    this.scale = 1.0,
  });

  final TextEditingController controller;
  final String hint;
  final String iconAsset;
  final double iconWidth; // design points
  final double iconHeight;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? suffix;
  final Color borderColor;
  final ValueChanged<String>? onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      height: 55.3 * s,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(11 * s),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: (25.7 - iconWidth / 2) * s,
            top: 0,
            bottom: 0,
            child: Center(
              child: AppAssetIcon(
                iconAsset,
                width: iconWidth * s,
                height: iconHeight * s,
                color: AppColors.hint,
              ),
            ),
          ),
          Positioned(
            left: 48 * s,
            right: (suffix == null ? 16 : 52) * s,
            top: 0,
            bottom: 0,
            child: Center(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                autofillHints: autofillHints,
                onChanged: onChanged,
                autocorrect: false,
                enableSuggestions: !obscureText,
                cursorColor: AppColors.accent,
                style: AppTextStyles.fieldText.scaled(s),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: AppTextStyles.fieldHint.scaled(s),
                ),
              ),
            ),
          ),
          if (suffix != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 52 * s,
              child: suffix!,
            ),
        ],
      ),
    );
  }
}
