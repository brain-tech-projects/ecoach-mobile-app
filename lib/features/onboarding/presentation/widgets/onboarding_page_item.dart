import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_pill.dart';
import 'package:ecoach_pro/features/onboarding/domain/entities/onboarding_page_data.dart';

/// Content of a single slide, vertically centred in the space between the
/// logo and the page indicator. Falls back to scrolling if the content is
/// taller than the available space (tiny screens / large accessibility text).
class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({super.key, required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.s(24)),
                  child: _SlideContent(data: data, scale: r.scale),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.data, required this.scale});

  final OnboardingPageData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final title = data.title;
    final description = data.description;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingTitle.scaled(scale),
            ),
          ),
        if (title != null && data.chips.isNotEmpty) SizedBox(height: 40 * scale),
        for (int i = 0; i < data.chips.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 16 * scale),
          AppPill(label: data.chips[i], scale: scale),
        ],
        if (description != null)
          Padding(
            // Paragraph is narrower than the pills (48 pt side padding).
            padding: EdgeInsets.symmetric(horizontal: 24 * scale),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingBody.scaled(scale),
            ),
          ),
      ],
    );
  }
}