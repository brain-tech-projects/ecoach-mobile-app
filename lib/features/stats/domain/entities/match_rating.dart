import 'package:flutter/foundation.dart';

@immutable
class MatchRating {
  const MatchRating({
    required this.id,
    required this.name,
    required this.date,
    required this.goals,
    required this.assists,
    required this.saves,
    required this.passing,
    required this.dribbling,
    required this.shooting,
    required this.defending,
    required this.pace,
    required this.physical,
  });

  final String id;
  final String name;
  final String date;
  final int goals;
  final int assists;
  final int saves;
  final int passing;
  final int dribbling;
  final int shooting;
  final int defending;
  final int pace;
  final int physical;
}
