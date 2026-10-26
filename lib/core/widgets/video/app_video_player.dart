import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/play_overlay.dart';
import 'package:ecoach_pro/core/widgets/video/player_menu.dart';
import 'package:ecoach_pro/core/widgets/video/video_controls.dart';
import 'package:ecoach_pro/core/widgets/video/video_fullscreen_page.dart';

/// Rounded video player with custom controls (play/pause, seek, mute, speed,
/// fullscreen). Streams [url]; shows [posterAsset] until playback starts.
///
/// Give it a `key` that changes with the video (e.g. `ValueKey(video.id)`) so
/// switching videos creates a fresh player.
class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    super.key,
    required this.url,
    required this.height,
    required this.scale,
    this.posterAsset,
    this.autoPlay = false,
    this.onEnded,
  });

  final String url;

  /// Height in design points (width is the available width).
  final double height;
  final double scale;
  final String? posterAsset;
  final bool autoPlay;
  final VoidCallback? onEnded;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _c;
  Timer? _hideTimer;
  bool _controlsVisible = true;
  bool _failed = false;
  bool _endedFired = false;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createController();
  }

  void _createController() {
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..addListener(_onValue);
    _c.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      if (widget.autoPlay) _c.play();
    }).catchError((Object error, StackTrace stack) {
      AppLogger.error('Video failed to load', error: error, stackTrace: stack);
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _c.removeListener(_onValue);
    _c.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _c.value.isInitialized) _c.pause();
  }

  void _onValue() {
    final v = _c.value;
    if (v.hasError && !_failed) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (v.isInitialized && v.duration > Duration.zero) {
      final atEnd = v.position >= v.duration;
      if (atEnd && !_endedFired) {
        _endedFired = true;
        _hideTimer?.cancel();
        if (mounted) setState(() => _controlsVisible = true);
        widget.onEnded?.call();
      } else if (!atEnd) {
        _endedFired = false;
      }
    }
    if (v.isPlaying != _wasPlaying) {
      _wasPlaying = v.isPlaying;
      if (mounted) setState(() {});
      _restartHideTimer();
    }
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    if (!_c.value.isPlaying) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.value.isPlaying) setState(() => _controlsVisible = false);
    });
  }

  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _restartHideTimer();
  }

  Future<void> _togglePlay() async {
    final v = _c.value;
    if (!v.isInitialized) return;
    if (v.isPlaying) {
      await _c.pause();
    } else {
      if (v.position >= v.duration) await _c.seekTo(Duration.zero);
      await _c.play();
    }
    _showControls();
  }

  void _onSurfaceTap() {
    final started = _c.value.position > Duration.zero || _c.value.isPlaying;
    if (!started || _controlsVisible) {
      _togglePlay();
    } else {
      _showControls();
    }
  }

  Rect _globalRect() {
    final box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _openMenu() {
    _hideTimer?.cancel();
    showPlayerMenu(
      context,
      controller: _c,
      scale: widget.scale,
      anchor: _globalRect(),
    ).then((_) => _restartHideTimer());
  }

  Future<void> _openFullscreen() async {
    _hideTimer?.cancel();
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (_, _, _) => VideoFullscreenPage(controller: _c),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    if (mounted) _showControls();
  }

  void _retry() {
    _c.removeListener(_onValue);
    _c.dispose();
    setState(() {
      _failed = false;
      _endedFired = false;
      _wasPlaying = false;
    });
    _createController();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20 * s),
      child: SizedBox(
        width: double.infinity,
        height: widget.height * s,
        child: ColoredBox(
          color: Colors.black,
          child: _failed ? _buildError(s) : _buildPlayer(s),
        ),
      ),
    );
  }

  Widget _buildError(double s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.error_outline, color: Colors.white70, size: 32 * s),
          SizedBox(height: 6 * s),
          Text('Unable to load video', style: AppTextStyles.trainSubline.scaled(s)),
          TextButton(
            onPressed: _retry,
            child: Text('Retry', style: AppTextStyles.action.scaled(s)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(double s) {
    final initialized = _c.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (initialized)
          Center(
            child: AspectRatio(
              aspectRatio: _c.value.aspectRatio,
              child: VideoPlayer(_c),
            ),
          ),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _c,
          builder: (context, v, _) {
            final started =
                v.isInitialized && (v.isPlaying || v.position > Duration.zero);
            final poster = widget.posterAsset;
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (!started && poster != null)
                  Image.asset(poster, fit: BoxFit.cover),
                if ((!v.isInitialized && poster == null) ||
                    (v.isBuffering && started))
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
              ],
            );
          },
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onSurfaceTap,
        ),
        ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _c,
          builder: (context, v, _) {
            final ended = v.isInitialized &&
                v.duration > Duration.zero &&
                v.position >= v.duration;
            final show = !v.isPlaying && (v.position == Duration.zero || ended);
            return IgnorePointer(
              child: Center(
                child: AnimatedOpacity(
                  opacity: show ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: PlayOverlay(size: 40 * s),
                ),
              ),
            );
          },
        ),
        if (initialized)
          AnimatedOpacity(
            opacity: _controlsVisible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_controlsVisible,
              child: VideoControls(
                controller: _c,
                scale: s,
                onTogglePlay: _togglePlay,
                onToggleMute: () {
                  _c.setVolume(_c.value.volume == 0 ? 1 : 0);
                  _showControls();
                },
                onFullscreen: _openFullscreen,
                onMore: _openMenu,
                onInteraction: _showControls,
              ),
            ),
          ),
      ],
    );
  }
}
