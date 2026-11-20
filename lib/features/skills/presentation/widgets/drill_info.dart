import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Title, description, "Top Tip" chip and bullet card under a video.
///
/// Everything is dynamic: a part is shown only when the API sent it, and the
/// space above "Video Complete" adapts (see [gapBeforeButton]).
class DrillInfo extends StatelessWidget {
  const DrillInfo({
    super.key,
    required this.title,
    required this.scale,
    this.description = '',
    this.topTip = '',
    this.keyPoints = const <String>[],
  });

  final String title;
  final String description;
  final String topTip;
  final List<String> keyPoints;
  final double scale;

  bool get _hasExtras => topTip.isNotEmpty || keyPoints.isNotEmpty;

  /// Space between this block and the "Video Complete" button.
  double get gapBeforeButton => (_hasExtras ? 24.3 : 43) * scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: AppTextStyles.sectionHeading.scaled(s)),
        if (description.isNotEmpty) ...<Widget>[
          SizedBox(height: 8.2 * s),
          Text(description, style: AppTextStyles.detailDesc.scaled(s)),
        ],
        if (topTip.isNotEmpty) ...<Widget>[
          SizedBox(height: 24 * s),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16 * s,
            runSpacing: 8 * s,
            children: <Widget>[
              Text('Top Tip:', style: AppTextStyles.sectionHeading.scaled(s)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13 * s, vertical: 9 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4A5C),
                  borderRadius: BorderRadius.circular(26 * s),
                ),
                child: Text(
                  topTip,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16 * s,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (keyPoints.isNotEmpty) ...<Widget>[
          SizedBox(height: 32 * s),
          Container(
            padding: EdgeInsets.fromLTRB(16 * s, 18 * s, 16 * s, 18 * s),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(18 * s),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var i = 0; i < keyPoints.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 20 * s),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 8 * s),
                        child: Container(
                          width: 9 * s,
                          height: 9 * s,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 14 * s),
                      Expanded(
                        child: Text(
                          keyPoints[i],
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16 * s,
                            height: 1.5,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
