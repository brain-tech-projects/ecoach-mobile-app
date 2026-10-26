import 'package:flutter/foundation.dart';

/// A training level (e.g. FUNDAMENTALS) made of numbered videos that unlock
/// one after another.
@immutable
class TrainingLevel {
  const TrainingLevel({
    required this.id,
    required this.title,
    required this.unlocked,
    required this.total,
    required this.imageAsset,
  });

  final String id;
  final String title;

  /// How many videos are unlocked (1 = only the first).
  final int unlocked;
  final int total;
  final String imageAsset;

  double get progress => total == 0 ? 0 : unlocked / total;
  int get percent => (progress * 100).round();
}

@immutable
class TrainingVideo {
  const TrainingVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.points = 10,
  });

  final String id;
  final String title; // e.g. "Fundamental #1"
  final String videoUrl;
  final int points;
}
