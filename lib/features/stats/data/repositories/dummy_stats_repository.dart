import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';
import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';

class DummyStatsRepository implements StatsRepository {
  @override
  Future<List<PointHistoryEntry>> fetchPointHistory() async => const [
        PointHistoryEntry(
          title: '#8 Dribble and Turn Complete!',
          date: '23 October 2026 10:44 AM',
          points: '10.00',
        ),
        PointHistoryEntry(
          title: '#8 Dribble and Turn Complete!',
          date: '23 October 2026 10:44 AM',
          points: '10.00',
        ),
        PointHistoryEntry(
          title: '#8 Dribble and Turn Complete!',
          date: '23 October 2026 10:43 AM',
          points: '10.00',
        ),
        PointHistoryEntry(
          title: '#8 Dribble and Turn Complete!',
          date: '23 October 2026 10:42 AM',
          points: '10.00',
        ),
        PointHistoryEntry(
          title: '#4 Heels Up Complete!',
          date: '13 October 2026 09:57 AM',
          points: '10.00',
        ),
        PointHistoryEntry(
          title: '#3 Knees Up Complete!',
          date: '13 October 2026 09:57 AM',
          points: '10.00',
        ),
      ];

  @override
  Future<List<MatchRating>> fetchMatchRatings() async => const [
        MatchRating(
          id: 'rcb-2026-10-08',
          name: 'rcb',
          date: 'OCTOBER 8, 2026',
          goals: 6,
          assists: 5,
          saves: 4,
          passing: 3,
          dribbling: 5,
          shooting: 3,
          defending: 3,
          pace: 3,
          physical: 5,
        ),
      ];
}
