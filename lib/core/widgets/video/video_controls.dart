import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Bottom control bar drawn over the video: play/pause, time, mute,
/// fullscreen, more (speed menu) and a seek bar.
class VideoControls extends StatelessWidget {
  const VideoControls({
    super.key,
    required this.controller,
    required this.scale,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onFullscreen,
    required this.onMore,
    required this.onInteraction,
    this.isFullscreen = false,
  });

  final VideoPlayerController controller;
  final double scale;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onFullscreen;
  final VoidCallback onMore;
  final VoidCallback onInteraction;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, v, _) {
        final muted = v.volume == 0;
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90 * s,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x00000000), Color(0xF2000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30 * s,
              height: 36 * s,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 6 * s),
                  _IconBtn(
                    icon: v.isPlaying ? Icons.pause : Icons.play_arrow,
                    scale: s,
                    label: v.isPlaying ? 'Pause' : 'Play',
                    onTap: onTogglePlay,
                  ),
                  SizedBox(width: 6 * s),
                  Text(
                    '${formatDuration(v.position)} / ${formatDuration(v.duration)}',
                    style: AppTextStyles.videoTime.scaled(s),
                  ),
                  const Spacer(),
                  _IconBtn(
                    icon: muted ? Icons.volume_off : Icons.volume_up,
                    scale: s,
                    label: muted ? 'Unmute' : 'Mute',
                    onTap: onToggleMute,
                  ),
                  SizedBox(width: 12 * s),
                  _IconBtn(
                    icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    scale: s,
                    label: isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
                    onTap: onFullscreen,
                  ),
                  SizedBox(width: 12 * s),
                  _IconBtn(
                    icon: Icons.more_vert,
                    scale: s,
                    label: 'More options',
                    onTap: onMore,
                  ),
                  SizedBox(width: 6 * s),
                ],
              ),
            ),
            Positioned(
              left: 16 * s,
              right: 16 * s,
              bottom: 10.3 * s,
              height: 24 * s,
              child: _SeekBar(
                controller: controller,
                value: v,
                scale: s,
                onInteraction: onInteraction,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 36 * scale,
          height: 36 * scale,
          child: Icon(icon, size: 24 * scale, color: Colors.white),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({
    required this.controller,
    required this.value,
    required this.scale,
    required this.onInteraction,
  });

  final VideoPlayerController controller;
  final VideoPlayerValue value;
  final double scale;
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final total = value.duration.inMilliseconds;
    final fraction = total == 0
        ? 0.0
        : (value.position.inMilliseconds / total).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        void seekTo(double dx) {
          if (total == 0) return;
          final f = (dx / width).clamp(0.0, 1.0);
          controller.seekTo(Duration(milliseconds: (total * f).round()));
          onInteraction();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => seekTo(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => seekTo(d.localPosition.dx),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                height: 4 * s,
                decoration: BoxDecoration(
                  color: const Color(0x4DFFFFFF),
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
              Container(
                width: width * fraction,
                height: 4 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2 * s),
                ),
              ),
              Positioned(
                left: width * fraction - 6 * s,
                child: Container(
                  width: 12 * s,
                  height: 12 * s,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
