import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';
import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';

abstract interface class StatsRepository {
  Future<List<PointHistoryEntry>> fetchPointHistory();
  Future<List<MatchRating>> fetchMatchRatings();
}
