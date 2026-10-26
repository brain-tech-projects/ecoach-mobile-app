import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:ecoach_pro/core/widgets/video/player_menu.dart';
import 'package:ecoach_pro/core/widgets/video/video_controls.dart';

/// Landscape fullscreen view that re-uses the inline player's controller
/// (playback continues seamlessly). Restores portrait on exit.
class VideoFullscreenPage extends StatefulWidget {
  const VideoFullscreenPage({super.key, required this.controller});

  final VideoPlayerController controller;

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> {
  Timer? _hideTimer;
  bool _visible = true;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _restartHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.value.isPlaying) setState(() => _visible = false);
    });
  }

  void _show() {
    setState(() => _visible = true);
    _restartHideTimer();
  }

  void _togglePlay() {
    _c.value.isPlaying ? _c.pause() : _c.play();
    _show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: _c.value.aspectRatio,
              child: VideoPlayer(_c),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _visible ? _togglePlay() : _show(),
          ),
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_visible,
              child: SafeArea(
                child: VideoControls(
                  controller: _c,
                  scale: 1.1,
                  isFullscreen: true,
                  onTogglePlay: _togglePlay,
                  onToggleMute: () {
                    _c.setVolume(_c.value.volume == 0 ? 1 : 0);
                    _show();
                  },
                  onFullscreen: () => Navigator.of(context).pop(),
                  onMore: () {
                    _hideTimer?.cancel();
                    showPlayerMenu(
                      context,
                      controller: _c,
                      scale: 1.1,
                      anchor: Offset.zero & MediaQuery.sizeOf(context),
                    ).then((_) => _restartHideTimer());
                  },
                  onInteraction: _show,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
