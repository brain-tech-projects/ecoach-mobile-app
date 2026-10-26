import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/settings/data/terms_of_use_content.dart';

/// "Terms of Use" header card that expands to a fixed-height, scrollable
/// text panel.
class TermsAccordion extends StatelessWidget {
  const TermsAccordion({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.scale,
  });

  final bool expanded;
  final VoidCallback onToggle;
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
          label: 'Terms of Use',
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
                      child: Text(
                        'Terms of Use',
                        style: AppTextStyles.termsHeader.scaled(s),
                      ),
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
              ? Padding(
                  padding: EdgeInsets.only(top: 20.7 * s),
                  child: _TermsContent(scale: s),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final style = AppTextStyles.termsBody.scaled(s);

    return Container(
      height: 467 * s,
      decoration: BoxDecoration(
        color: AppColors.termsContentFill,
        borderRadius: BorderRadius.circular(11.5 * s),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.3 * s, 13.5 * s, 18.3 * s, 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TermsOfUseContent.updated, style: style),
            for (final paragraph in TermsOfUseContent.paragraphs) ...<Widget>[
              SizedBox(height: 19.6 * s),
              Text(paragraph, style: style),
            ],
          ],
        ),
      ),
    );
  }
}
