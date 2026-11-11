import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';

class ApiTrackerRepository implements TrackerRepository {
  ApiTrackerRepository(this._api, this._session);

  final ApiService _api;
  final SessionService _session;

  static int _id(String id) => int.tryParse(id) ?? 0;

  static int _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? 0}') ?? 0;

  /// List uses "01/27/26" (MM/dd/yy), details use "2026-01-27".
  static DateTime _date(Object? v) {
    final text = '${v ?? ''}'.trim();
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;
    final p = text.split('/');
    if (p.length == 3) {
      final m = int.tryParse(p[0]);
      final d = int.tryParse(p[1]);
      var y = int.tryParse(p[2]);
      if (m != null && d != null && y != null) {
        // Two-digit years: 00-49 -> 20xx, 50-99 -> 19xx (same as the web).
        if (y < 100) y += y < 50 ? 2000 : 1900;
        return DateTime(y, m, d);
      }
    }
    return DateTime.now();
  }

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static MatchEntry _entry(Map<dynamic, dynamic> m) => MatchEntry(
    id: '${m['id']}',
    opponent: (m['opponent_team'] ?? '').toString(),
    playedOn: _date(m['match_date']),
    score: (m['score'] ?? '').toString(),
    passing: _int(m['passing']),
    dribbling: _int(m['dribbling']),
    shooting: _int(m['shooting']),
    defending: _int(m['defending']),
    pace: _int(m['pace']),
    physicality: _int(m['physicality']),
    assists: _int(m['assists']),
    goals: _int(m['goals']),
    saves: _int(m['saves']),
    photoUrl: Env.skillMediaUrl(m['match_photo'] as String?),
  );

  /// "Subscription required" opens the Subscription page.
  ApiResponse<T> _guard<T>(ApiResponse<T> res) {
    if (res.isSubscriptionRequired && Get.currentRoute != AppRoutes.subscription) {
      Get.toNamed<void>(AppRoutes.subscription);
    }
    return res;
  }

  ApiResponse<R> _fail<R>(ApiResponse<dynamic> res) => ApiResponse<R>(
    success: false,
    message: res.message,
    statusCode: res.statusCode,
    errors: res.errors,
  );

  @override
  Future<ApiResponse<TrackerData>> fetchTracker() async {
    final res = _guard(await _api.getRatingTrackerList());
    final d = res.data;
    if (!res.success || d is! Map) return _fail<TrackerData>(res);

    final matches = d['matches'];
    final entries = <MatchEntry>[
      if (matches is List) for (final m in matches.whereType<Map>()) _entry(m),
    ]..sort((a, b) => b.playedOn.compareTo(a.playedOn));

    return ApiResponse<TrackerData>(
      success: true,
      message: res.message,
      data: TrackerData(
        // Name and photo of the signed-in player (UserModel), not the
        // nickname the tracker API sends back.
        playerName: _playerName(),
        photoUrl: _session.user.value?.profilePhoto,
        entries: entries,
      ),
    );
  }

  /// Full name first ("Virat"), then nickname, then email.
  String _playerName() {
    final u = _session.user.value;
    if (u == null) return '';
    final full = (u.fullName ?? '').trim();
    return full.isNotEmpty ? full : u.displayName;
  }

  @override
  Future<bool> canAddMatch() async {
    final res = await _api.canAddMatch();
    return res.success && res.body?['can_add_match'] == true;
  }

  @override
  Future<ApiResponse<MatchEntry>> fetchMatch(String id) async {
    final res = _guard(await _api.getRatingTrackerDetail(_id(id)));
    final d = res.data;
    final first = d is List && d.isNotEmpty ? d.first : (d is Map ? d : null);
    if (!res.success || first is! Map) return _fail<MatchEntry>(res);
    return ApiResponse<MatchEntry>(
      success: true,
      message: res.message,
      data: _entry(first),
    );
  }

  @override
  Future<ApiResponse<MatchEntry>> saveMatch(MatchEntry e) async {
    final res = _guard(
      await _api.saveRatingTracker(
        id: e.id.isEmpty ? null : _id(e.id),
        photoPath: e.photoPath,
        fields: <String, dynamic>{
          'opponent_team': e.opponent,
          'match_date': _ymd(e.playedOn),
          'score': e.score,
          'passing': e.passing,
          'dribbling': e.dribbling,
          'shooting': e.shooting,
          'defending': e.defending,
          'pace': e.pace,
          'physicality': e.physicality,
          'assists': e.assists,
          'goals': e.goals,
          'saves': e.saves,
        },
      ),
    );
    return res.success
        ? ApiResponse<MatchEntry>(success: true, message: res.message, data: e)
        : _fail<MatchEntry>(res);
  }

  @override
  Future<ApiResponse<void>> deleteMatch(String id) async {
    final res = _guard(await _api.deleteRatingTracker(_id(id)));
    return ApiResponse<void>(
      success: res.success,
      message: res.message,
      statusCode: res.statusCode,
    );
  }
}
