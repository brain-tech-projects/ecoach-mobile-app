import 'package:flutter/foundation.dart';

@immutable
class PointHistoryEntry {
  const PointHistoryEntry({
    required this.title,
    required this.date,
    required this.points,
  });

  final String title;
  final String date;
  final String points;
}
