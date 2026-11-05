import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Same look as the Terms of Use header, for any content.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    required this.scale,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          expanded: expanded,
          label: title,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                height: 52.7 * s,
                padding: EdgeInsets.only(left: 19.3 * s, right: 15.7 * s),
                decoration: BoxDecoration(
                  color: AppColors.termsCardFill,
                  border: Border.all(color: AppColors.termsCardBorder),
                  borderRadius: BorderRadius.circular(11.5 * s),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: AppTextStyles.termsHeader.scaled(s)),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 26 * s,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(padding: EdgeInsets.only(top: 12 * s), child: child)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
