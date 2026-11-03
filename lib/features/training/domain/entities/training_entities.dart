import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/core/config/env.dart';

int _int(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

/// A training level (FUNDAMENTALS, INTERMEDIATE, ADVANCED...) from
/// `GET /training-types`.
@immutable
class TrainingLevel {
  const TrainingLevel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.completed = 0,
    this.total = 0,
    this.locked = false,
  });

  factory TrainingLevel.fromJson(Map<String, dynamic> json) => TrainingLevel(
    id: _int(json['id']),
    title: (json['name'] ?? '').toString(),
    imageUrl: Env.mediaUrl(json['image'] as String?),
    completed: _int(json['videos_completed']),
    total: _int(json['videos_count']),
    locked: json['locked'] == true,
  );

  final int id;
  final String title;
  final String? imageUrl;

  /// Videos finished / videos in the level (the "1/23" badge).
  final int completed;
  final int total;
  final bool locked;

  double get progress => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
  int get percent => (progress * 100).round();
}

/// `GET /training-types`: every level + the name of the user's current one.
@immutable
class TrainingOverview {
  const TrainingOverview({required this.levels, this.currentTitle});

  final List<TrainingLevel> levels;
  final String? currentTitle;

  TrainingLevel? get current {
    if (levels.isEmpty) return null;
    for (final level in levels) {
      if (level.title == currentTitle) return level;
    }
    return levels.first;
  }
}

/// One numbered video of a level, from `POST /training-videos`.
@immutable
class TrainingVideo {
  const TrainingVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.imageUrl,
    this.points = 0,
    this.completed = false,
    this.locked = false,
    this.availableIn,
  });

  factory TrainingVideo.fromJson(Map<String, dynamic> json) {
    final availableIn = json['available_in'];
    return TrainingVideo(
      id: _int(json['id']),
      title: (json['title'] ?? '').toString(),
      videoUrl: Env.mediaUrl(json['video'] as String?) ?? '',
      imageUrl: Env.mediaUrl(json['image'] as String?),
      points: _int(json['reward_points']),
      completed: json['completed'] == true,
      locked: json['locked'] == true,
      // "1 day 4 hours" while locked, 0 once available.
      availableIn: availableIn is String && availableIn.isNotEmpty
          ? availableIn
          : null,
    );
  }

  final int id;
  final String title; // e.g. "Fundamental #1"
  final String videoUrl;
  final String? imageUrl;
  final int points;
  final bool completed;
  final bool locked;

  /// Time until it unlocks ("1 day 4 hours"), null when not applicable.
  final String? availableIn;
}
