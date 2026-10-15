import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Full-width green pill button with a dark arrow badge on the right.
/// A `null` [onPressed] keeps the same look (used for "not wired yet").
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.scale = 1.0,
    this.labelStyle = AppTextStyles.buttonLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final double scale;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final height = 58 * scale;
    final radius = BorderRadius.circular(height / 2);

    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: radius,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.buttonGlow,
                blurRadius: 28,
                spreadRadius: -4,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: radius,
              child: SizedBox(
                height: height,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 52 * scale),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: labelStyle.scaled(scale),
                      ),
                    ),
                    Positioned(
                      right: 16 * scale,
                      child: Container(
                        width: 30 * scale,
                        height: 30 * scale,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 18 * scale,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
