import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Everything under the video on a video detail screen, driven only by
/// what the API sends:
///
///   title
///   description                      (when not empty)
///   Top Tip: [chip]                  (when [topTip] is not empty)
///   bullet box                       (when [points] is not empty)
///
/// Nothing is invented: a field the API leaves empty is simply not drawn.
class VideoInfoSection extends StatelessWidget {
  const VideoInfoSection({
    super.key,
    required this.title,
    required this.scale,
    this.description = '',
    this.topTip = '',
    this.points = const <String>[],
  });

  final String title;
  final String description;
  final String topTip;
  final List<String> points;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final hasDescription = description.trim().isNotEmpty;
    final hasTip = topTip.trim().isNotEmpty;
    final hasPoints = points.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: AppTextStyles.sectionHeading.scaled(s)),
        if (hasDescription) ...<Widget>[
          SizedBox(height: 8.2 * s),
          Text(description, style: AppTextStyles.detailDesc.scaled(s)),
        ],
        if (hasTip) ...<Widget>[
          SizedBox(height: 18 * s),
          _TopTip(text: topTip, scale: s),
        ],
        if (hasPoints) ...<Widget>[
          SizedBox(height: 24 * s),
          _PointsBox(points: points, scale: s),
        ],
      ],
    );
  }
}

class _TopTip extends StatelessWidget {
  const _TopTip({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12 * s,
      runSpacing: 8 * s,
      children: <Widget>[
        Text('Top Tip:', style: AppTextStyles.infoLabel.scaled(s)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 13 * s, vertical: 6.5 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1E4A5C),
            borderRadius: BorderRadius.circular(40 * s),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12 * s,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PointsBox extends StatelessWidget {
  const _PointsBox({required this.points, required this.scale});

  final List<String> points;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.fromLTRB(16 * s, 16 * s, 16 * s, 16 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(10.5 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < points.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: 14 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 6 * s),
                  child: Container(
                    width: 8 * s,
                    height: 8 * s,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Text(
                    points[i],
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w400,
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
    );
  }
}
