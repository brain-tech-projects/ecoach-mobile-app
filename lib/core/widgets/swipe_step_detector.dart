import 'package:flutter/material.dart';

/// Finger-swipe navigation between the steps of a multi-step flow, like a
/// native app: swipe right-to-left = next step, left-to-right = previous.
///
/// Works the same on iOS and Android. It only reacts to clearly horizontal
/// drags (so vertical scrolling and text fields keep working) and ignores
/// drags that start at the very left edge so the iOS "swipe back to the
/// previous page" gesture is never fought.
class SwipeStepDetector extends StatefulWidget {
  const SwipeStepDetector({
    super.key,
    required this.child,
    this.onNext,
    this.onPrevious,
    this.edgeInset = 24,
    this.minDistance = 56,
    this.minVelocity = 320,
  });

  final Widget child;

  /// Finger moved right -> left.
  final VoidCallback? onNext;

  /// Finger moved left -> right.
  final VoidCallback? onPrevious;

  /// Drags starting closer than this to the left screen edge are left to
  /// the OS (iOS back gesture).
  final double edgeInset;

  /// Minimum horizontal travel (logical px) for a slow drag to count.
  final double minDistance;

  /// Minimum fling speed (logical px / s) for a quick flick to count.
  final double minVelocity;

  @override
  State<SwipeStepDetector> createState() => _SwipeStepDetectorState();
}

class _SwipeStepDetectorState extends State<SwipeStepDetector> {
  double _dx = 0;
  bool _ignore = false;

  void _onStart(DragStartDetails d) {
    _dx = 0;
    _ignore = d.globalPosition.dx < widget.edgeInset;
  }

  void _onUpdate(DragUpdateDetails d) {
    if (_ignore) return;
    _dx += d.delta.dx;
  }

  void _onEnd(DragEndDetails d) {
    if (_ignore) return;
    final v = d.primaryVelocity ?? 0;
    final byDistance = _dx.abs() >= widget.minDistance;
    final byFling = v.abs() >= widget.minVelocity && _dx.abs() >= 16;
    if (!byDistance && !byFling) return;

    // Direction comes from the real travel; fall back to fling direction.
    final goesNext = _dx != 0 ? _dx < 0 : v < 0;
    if (goesNext) {
      widget.onNext?.call();
    } else {
      widget.onPrevious?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onStart,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      child: widget.child,
    );
  }
}
