import 'package:flutter/foundation.dart';

/// The coach the player is connected to.
@immutable
class Coach {
  const Coach({
    required this.id,
    required this.name,
    required this.team,
    this.avatarAsset,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String team;

  /// `assets/...` (dummy data) or [avatarUrl] (API).
  final String? avatarAsset;
  final String? avatarUrl;
}

/// A skill / training the coach set for the player ("My Training").
@immutable
class AssignedTraining {
  const AssignedTraining({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  final String id;
  final String title;
  final String videoUrl;
}
