import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/floating_panel.dart';

/// "More" menu of the video player: Playback speed -> list of speeds.
/// [anchor] is the player's rectangle in global coordinates.
Future<void> showPlayerMenu(
  BuildContext context, {
  required VideoPlayerController controller,
  required double scale,
  required Rect anchor,
}) {
  final screen = MediaQuery.sizeOf(context);
  return showFloatingPanel<void>(
    context,
    width: 200 * scale,
    right: screen.width - (anchor.right - 4 * scale),
    bottom: screen.height - (anchor.bottom - 28.3 * scale),
    builder: (dialogContext) => _PlayerMenu(
      controller: controller,
      scale: scale,
      onClose: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

class _PlayerMenu extends StatefulWidget {
  const _PlayerMenu({
    required this.controller,
    required this.scale,
    required this.onClose,
  });

  final VideoPlayerController controller;
  final double scale;
  final VoidCallback onClose;

  @override
  State<_PlayerMenu> createState() => _PlayerMenuState();
}

class _PlayerMenuState extends State<_PlayerMenu> {
  static const List<double> _speeds = <double>[
    0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, //
  ];

  bool _speedPage = false;

  String _label(double v) => v == 1.0 ? 'Normal' : '$v';

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final style = AppTextStyles.playerMenu.scaled(s);
    final current = widget.controller.value.playbackSpeed;

    final rows = _speedPage
        ? <Widget>[
            _Row(
              height: 48 * s,
              onTap: () => setState(() => _speedPage = false),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 16 * s),
                  Icon(Icons.arrow_back, size: 22 * s, color: AppColors.black),
                  SizedBox(width: 20 * s),
                  Text('Options', style: style),
                ],
              ),
            ),
            for (final v in _speeds)
              _Row(
                height: 48 * s,
                onTap: () {
                  widget.controller.setPlaybackSpeed(v);
                  widget.onClose();
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 58 * s),
                    Expanded(child: Text(_label(v), style: style)),
                    if (v == current)
                      Padding(
                        padding: EdgeInsets.only(right: 20 * s),
                        child: Icon(Icons.check, size: 22 * s, color: AppColors.checkBlue),
                      ),
                  ],
                ),
              ),
          ]
        : <Widget>[
            _Row(
              height: 46 * s,
              onTap: () => setState(() => _speedPage = true),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 16 * s),
                  Icon(Icons.slow_motion_video, size: 22 * s, color: AppColors.black),
                  SizedBox(width: 16 * s),
                  Text('Playback speed', style: style),
                ],
              ),
            ),
          ];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 250 * s),
      child: Material(
        color: AppColors.white,
        elevation: 6,
        borderRadius: BorderRadius.circular(4 * s),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: rows)),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.height, required this.onTap, required this.child});

  final double height;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      InkWell(onTap: onTap, child: SizedBox(height: height, child: child));
}
