import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/dashboard/data/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Banners from `GET /banners`: image, always-playing muted video, or text.
/// Several banners become a swipeable carousel with dots.
class BannerView extends StatefulWidget {
  const BannerView({super.key, required this.banners, required this.scale});

  final List<BannerModel> banners;
  final double scale;

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final items = widget.banners;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10 * s),
          child: AspectRatio(
            aspectRatio: 3.2,
            child: ColoredBox(
              color: Colors.black,
              child: PageView.builder(
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _BannerItem(banner: items[i], scale: s),
              ),
            ),
          ),
        ),
        if (items.length > 1) ...<Widget>[
          SizedBox(height: 8 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < items.length; i++)
                Container(
                  width: 6 * s,
                  height: 6 * s,
                  margin: EdgeInsets.symmetric(horizontal: 3 * s),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? AppColors.accent : AppColors.dotInactive,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  const _BannerItem({required this.banner, required this.scale});

  final BannerModel banner;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (banner.isVideo) return _BannerVideo(url: banner.video!);

    if (banner.isImage) {
      return Image.network(
        banner.banner!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Text(
          banner.text ?? banner.title ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyles.heroTitle.scaled(scale),
        ),
      ),
    );
  }
}

/// Always plays: muted, looping, starts by itself, and keeps going after the
/// app returns from the background. No tap-to-pause.
class _BannerVideo extends StatefulWidget {
  const _BannerVideo({required this.url});

  final String url;

  @override
  State<_BannerVideo> createState() => _BannerVideoState();
}

class _BannerVideoState extends State<_BannerVideo>
    with WidgetsBindingObserver {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      // Muted banner: do not steal audio focus from the user's music.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller.addListener(_keepPlaying);
    _controller
        .initialize()
        .then((_) async {
          if (!mounted) return;
          await _controller.setLooping(true);
          await _controller.setVolume(0);
          await _controller.play();
          if (mounted) setState(() => _ready = true);
        })
        .catchError((Object _) {
          if (mounted) setState(() => _failed = true);
        });
  }

  /// If the player stops for any reason (OS pause, buffering hiccup) while
  /// the app is visible, start it again.
  void _keepPlaying() {
    final v = _controller.value;
    if (_foreground && v.isInitialized && !v.isPlaying && !v.isBuffering) {
      _controller.play();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && _ready) _controller.play();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_keepPlaying)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const Center(
        child: Icon(Icons.videocam_off_outlined, color: AppColors.hint),
      );
    }
    if (!_ready) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.accent,
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}