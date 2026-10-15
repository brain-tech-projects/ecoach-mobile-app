import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// "Unleash Your Inner Champion" banner with three action pills.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.scale,
    this.onJoinNow,
    this.onTakeTour,
    this.onInstallApp,
  });

  final double scale;
  final VoidCallback? onJoinNow;
  final VoidCallback? onTakeTour;
  final VoidCallback? onInstallApp;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10 * s),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 152 * s),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF17513A),
                Color(0xFF0B3520),
                Color(0xFF041D06),
              ],
              stops: <double>[0, 0.55, 1],
            ),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.7),
                radius: 0.9,
                colors: <Color>[Color(0x66258A5E), Color(0x00258A5E)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(26 * s, 24 * s, 26 * s, 26 * s),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: 'Unleash Your Inner ',
                        children: const <InlineSpan>[
                          TextSpan(
                            text: 'Champion',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                      style: AppTextStyles.heroTitle.scaled(s),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      'Train Hard, Play Harder',
                      style: AppTextStyles.heroSubtitle.scaled(s),
                    ),
                    SizedBox(height: 16.5 * s),
                    Wrap(
                      spacing: 8 * s,
                      runSpacing: 8 * s,
                      children: <Widget>[
                        _HeroPill(label: 'Join Now', scale: s, onTap: onJoinNow),
                        _HeroPill(
                          label: 'Take The Tour',
                          scale: s,
                          onTap: onTakeTour,
                        ),
                        _HeroPill(
                          label: 'Install App',
                          scale: s,
                          onTap: onInstallApp,
                        ),
                      ],
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.scale, this.onTap});

  final String label;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 9.33 * scale,
            vertical: 7 * scale,
          ),
          child: Text(label, style: AppTextStyles.heroButton.scaled(scale)),
        ),
      ),
    );
  }
}
