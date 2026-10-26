import 'package:flutter/material.dart';

/// Shows [builder] as a floating panel (popup menu style) positioned with
/// screen-edge distances; tapping outside dismisses it. Pass any two of
/// left/right and top/bottom.
Future<T?> showFloatingPanel<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required double width,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (dialogContext, _, _) => Stack(
      children: <Widget>[
        Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          child: Material(
            type: MaterialType.transparency,
            child: builder(dialogContext),
          ),
        ),
      ],
    ),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
