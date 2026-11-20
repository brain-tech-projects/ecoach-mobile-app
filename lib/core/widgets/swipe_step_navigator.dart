import 'package:flutter/material.dart';

/// Lets the user move between wizard steps with a finger swipe.
///
/// * swipe right-to-left (finger moves left) -> [onNext]
/// * swipe left-to-right (finger moves right) -> [onPrevious]
///
/// Only a deliberate, mostly-horizontal flick counts, so vertical scrolling,
/// taps and text selection keep working. Works the same on iOS and Android.
class SwipeStepNavigator extends StatefulWidget {
  const SwipeStepNavigator({
    super.key,
    required this.child,
    required this.onNext,
    required this.onPrevious,
  });

  final Widget child;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<SwipeStepNavigator> createState() => _SwipeStepNavigatorState();
}

class _SwipeStepNavigatorState extends State<SwipeStepNavigator> {
  /// Minimum horizontal travel (logical px) and fling speed for a swipe.
  static const double _minDistance = 48;
  static const double _minVelocity = 300;

  double _dx = 0;

  void _end(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    final fastEnough = v.abs() >= _minVelocity;
    final farEnough = _dx.abs() >= _minDistance;
    if (fastEnough || farEnough) {
      final goNext = (v != 0 ? v : _dx) < 0;
      goNext ? widget.onNext() : widget.onPrevious();
    }
    _dx = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _dx = 0,
      onHorizontalDragUpdate: (d) => _dx += d.delta.dx,
      onHorizontalDragEnd: _end,
      onHorizontalDragCancel: () => _dx = 0,
      child: widget.child,
    );
  }
}
