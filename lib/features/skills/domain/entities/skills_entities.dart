import 'package:flutter/foundation.dart';

@immutable
class SkillCategory {
  const SkillCategory({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String imageAsset;
}

/// A skill video ("drill").
@immutable
class Drill {
  const Drill({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    this.focus = '',
    this.equipment = '',
    this.views = 0,
    this.points = 10,
    this.thumbnailAspect = 327 / 280,
    this.posterAsset,
  });

  final String id;
  final String title; // e.g. "#8 Dribble and Turn"
  final String description;
  final String focus;
  final String equipment;
  final int views;
  final int points;

  /// An `assets/...` path (dummy data) or an `https://...` URL (API).
  final String thumbnail;

  /// width / height of the list thumbnail.
  final double thumbnailAspect;
  final String videoUrl;

  /// Shown on the player before playback starts.
  final String? posterAsset;
}
