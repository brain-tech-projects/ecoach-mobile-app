import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

/// Row of dots; the current one grows (12 -> 15 pt) and turns bright green.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.scale = 1.0,
    this.activeColor = AppColors.dotActive,
    this.inactiveColor = AppColors.dotInactive,
  });

  static const double _dotSize = 12;
  static const double _activeSize = 15;
  static const double _gap = 8;

  final int count;
  final int currentIndex;
  final double scale;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentIndex + 1} of $count',
      child: ExcludeSemantics(
        child: SizedBox(
          height: _activeSize * scale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < count; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : _gap * scale),
                  child: _Dot(
                    size: (i == currentIndex ? _activeSize : _dotSize) * scale,
                    color: i == currentIndex ? activeColor : inactiveColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}