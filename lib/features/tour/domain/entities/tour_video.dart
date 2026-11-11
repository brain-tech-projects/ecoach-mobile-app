import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/core/config/env.dart';

/// One "Take the tour" video (`GET /tour-videos`).
@immutable
class TourVideo {
  const TourVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.posterUrl,
    this.order = 0,
  });

  factory TourVideo.fromJson(Map<String, dynamic> json) => TourVideo(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    videoUrl: (Env.skillMediaUrl(json['video'] as String?) ?? '').replaceAll(' ', '%20'),
    posterUrl: Env.skillMediaUrl(json['image'] as String?),
    order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order'] ?? 0}') ?? 0,
  );

  final int id;
  final String title;
  final String description;
  final String videoUrl;

  /// Thumbnail in the strip (full URL, null when the video has no image).
  final String? posterUrl;

  /// Play order from the backend.
  final int order;
}
