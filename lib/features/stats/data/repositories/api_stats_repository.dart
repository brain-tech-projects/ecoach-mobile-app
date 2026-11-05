import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/stats/domain/entities/match_rating.dart';
import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';

class ApiStatsRepository implements StatsRepository {
  ApiStatsRepository(this._api);

  final ApiService _api;

  static int _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;

  @override
  Future<List<PointHistoryEntry>> fetchPointHistory() async {
    final res = requireSuccess(await _api.getPointsHistory());
    final d = res.data;
    if (d is! List) return const <PointHistoryEntry>[];

    return <PointHistoryEntry>[
      for (final e in d.whereType<Map>())
        PointHistoryEntry(
          title: '${e['video_title'] ?? ''} Complete!',
          date: (e['completed_at'] ?? '').toString(),
          points: (e['points_earned'] is num
                  ? (e['points_earned'] as num).toDouble()
                  : double.tryParse('${e['points_earned'] ?? 0}') ?? 0)
              .toStringAsFixed(2),
        ),
    ];
  }

  @override
  Future<List<MatchRating>> fetchMatchRatings() async {
    final res = requireSuccess(await _api.getRatingTrackerList());
    final d = res.data;
    final matches = d is Map ? d['matches'] : null;
    if (matches is! List) return const <MatchRating>[];

    DateTime date(Object? v) {
      final p = '${v ?? ''}'.split('/');
      if (p.length == 3) {
        final m = int.tryParse(p[0]);
        final day = int.tryParse(p[1]);
        final y = int.tryParse(p[2]);
        if (m != null && day != null && y != null) {
          return DateTime(y < 100 ? y + 2000 : y, m, day);
        }
      }
      return DateTime.tryParse('${v ?? ''}') ?? DateTime.now();
    }

    return <MatchRating>[
      for (final m in matches.whereType<Map>())
        MatchRating(
          id: '${m['id']}',
          name: (m['opponent_team'] ?? '').toString(),
          date: TrackerFormat.longDate(date(m['match_date'])),
          goals: _int(m['goals']),
          assists: _int(m['assists']),
          saves: _int(m['saves']),
          passing: _int(m['passing']),
          dribbling: _int(m['dribbling']),
          shooting: _int(m['shooting']),
          defending: _int(m['defending']),
          pace: _int(m['pace']),
          physical: _int(m['physicality']),
        ),
    ];
  }
}
