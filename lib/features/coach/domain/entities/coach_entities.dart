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
    this.description = '',
    this.topTip = '',
    this.instructions = const <String>[],
  });

  final String id;
  final String title;
  final String videoUrl;

  /// Optional extras from the API (empty = not shown).
  final String description;
  final String topTip;
  final List<String> instructions;
}

/// A pending invitation a coach sent to this player.
class CoachInvite {
  const CoachInvite({
    required this.id,
    required this.name,
    this.subtitle = '',
    this.avatarUrl,
  });

  final int id;
  final String name;

  /// "position . club" (parts that exist).
  final String subtitle;
  final String? avatarUrl;
}
