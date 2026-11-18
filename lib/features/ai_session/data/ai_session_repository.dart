import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';

void ensureAiSessionRepository() {
  if (!Get.isRegistered<AiSessionRepository>()) {
    Get.put<AiSessionRepository>(AiSessionRepository(), permanent: true);
  }
}

/// First name for "Hi Virat".
String aiFirstName() {
  final user = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
  final name = (user?.fullName ?? '').trim();
  return name.isEmpty ? 'there' : name.split(' ').first;
}

/// The backend asked for a subscription while building a session.
class AiSubscriptionRequired implements Exception {
  const AiSubscriptionRequired();
}

/// AI training sessions (`/ai/*`). Talks to [ApiService] only.
class AiSessionRepository {
  AiSessionRepository({ApiService? api}) : _api = api ?? Get.find<ApiService>();

  final ApiService _api;

  static const List<AiChip> chips = <AiChip>[
    AiChip('Dribbling', '⚡', 'I want to work on my dribbling.'),
    AiChip('First touch', '🎯', 'I want to work on my first touch.'),
    AiChip('Passing', '🔁', 'I want to work on my passing.'),
    AiChip('Shooting', '🥅', 'I want to work on my shooting.'),
    AiChip('Weaker foot', '🦶', 'I want to work on my weaker foot.'),
    AiChip('Speed', '💨', 'I want to work on my speed.'),
    AiChip('Match prep', '🏆', 'I have a match tomorrow and want to practise first touch.'),
  ];

  static const List<String> suggestions = <String>[
    'Help me beat players with better dribbling.',
    'Give me a session to improve my passing.',
    'I have a match tomorrow and want to practise first touch.',
    'I want to work on my dribbling, weaker foot and shooting.',
  ];

  /// "Personalised for you": the signed-in player's own profile.
  static AiProfile get profile {
    final u = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
    final age = u?.age;
    return AiProfile(
      age: (age == null || age <= 0) ? '' : '$age years old',
      positions: u?.playingPosition ?? const <String>[],
      levels: u?.skillLevel ?? const <String>[],
      focus: u?.improveAreas ?? const <String>[],
    );
  }

  // ---- parsing helpers --------------------------------------------------------

  static String _s(Object? v) => (v ?? '').toString().trim();
  static int _i(Object? v, [int fallback = 0]) => v is int ? v : (int.tryParse('${v ?? ''}') ?? fallback);

  static List<Map<String, dynamic>> _maps(Object? v) => v is List ? <Map<String, dynamic>>[for (final e in v.whereType<Map>()) Map<String, dynamic>.from(e)] : <Map<String, dynamic>>[];

  /// "Today", "Yesterday", "6 days ago", then the date.
  static String _when(String created) {
    final t = DateTime.tryParse(created)?.toLocal();
    if (t == null) return '';
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(t.year, t.month, t.day)).inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 30) return '$days days ago';
    const m = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${t.day} ${m[t.month - 1]} ${t.year}';
  }

  AiDrill _drill(Map<String, dynamic> d) {
    final categories = d['categories'] is List ? <String>[for (final c in d['categories'] as List) _s(c)].where((e) => e.isNotEmpty).toList() : <String>[];
    final reason = _s(d['match_reason']);
    final image = _s(d['image_url']).isNotEmpty ? _s(d['image_url']) : _s(d['image']);
    return AiDrill(
      id: _i(d['id']),
      title: _s(d['title']),
      category: _s(d['type_name']).isNotEmpty ? _s(d['type_name']) : (categories.isNotEmpty ? categories.first : 'Training'),
      description: _s(d['description']),
      note: reason.isEmpty ? 'Matches your request' : reason,
      thumb: image,
      videoUrl: _s(d['video']),
      mins: _i(d['duration_minutes'], 5),
      points: _i(d['reward_points'], 5),
      type: _s(d['drill_type']).isEmpty ? 'skill_video' : _s(d['drill_type']),
      completed: d['completed'] == true,
      locked: d['locked'] == true,
    );
  }

  /// "a, b and c"
  static String _natural(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    return '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}';
  }

  /// The API sends no summary text, so it is written from the drills.
  AiSession _toSession(Map<String, dynamic> d, String fallbackRequest) {
    var rows = _maps(d['drills']);
    if (rows.isEmpty) rows = <Map<String, dynamic>>[..._maps(d['training_videos']), ..._maps(d['skill_videos'])];
    final drills = <AiDrill>[for (final r in rows) _drill(r)];

    final tags = <String>[];
    for (final r in rows) {
      final list = r['categories'] is List ? r['categories'] as List : const <dynamic>[];
      for (final c in list) {
        final t = _s(c);
        if (t.isNotEmpty && !tags.contains(t)) tags.add(t);
      }
    }
    final shownTags = tags.take(4).toList();

    final user = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
    final level = (user?.skillLevel.isNotEmpty ?? false) ? user!.skillLevel.first.toLowerCase() : '';
    final age = user?.age ?? 0;
    final who = <String>[if (level.isNotEmpty) 'a $level player' else if (age > 0) 'a player', if (age > 0) 'aged $age'].join(' ');
    final focus = _natural(shownTags.map((e) => e.toLowerCase()).toList());
    final count = drills.length;
    final summary = StringBuffer('I picked $count ${count == 1 ? 'drill' : 'drills'}')
      ..write(focus.isEmpty ? '' : ' focused on $focus')
      ..write(who.isEmpty ? '' : ', set for $who')
      ..write('. Start with drill 1 and work your way through.');

    return AiSession(
      id: _i(d['session_id']),
      request: _s(d['prompt']).isNotEmpty ? _s(d['prompt']) : fallbackRequest,
      summary: summary.toString(),
      tags: shownTags,
      drills: drills,
      completed: d['is_completed'] == true,
    );
  }

  // ---- API --------------------------------------------------------------------

  Future<List<AiSessionSummary>> fetchRecent() async {
    final res = await _api.getAiSessions();
    if (!res.success) throw ApiException(res.message);
    return <AiSessionSummary>[
      for (final r in _maps(res.data))
        AiSessionSummary(
          id: _i(r['session_id']),
          request: _s(r['prompt_text']),
          when: _when(_s(r['created_at'])),
          drills: _i(r['training_video_count']) + _i(r['skill_video_count']),
          mins: _i(r['total_minutes'], 20),
        ),
    ];
  }

  /// Builds a new session. Throws [AiSubscriptionRequired] when a plan is needed.
  Future<AiSession> buildSession(String request) async {
    final res = await _api.generateAiSession(request);
    if (res.isSubscriptionRequired) throw const AiSubscriptionRequired();
    if (!res.success) throw ApiException(res.message);
    final d = res.data;
    if (d is! Map) throw ApiException('Could not build your session. Please try again.');
    final session = _toSession(Map<String, dynamic>.from(d), request);
    if (session.drills.isEmpty) throw ApiException('No drills matched your request. Please try a different one.');
    return session;
  }

  /// Re-opens a session from the recent list.
  Future<AiSession> fetchSession(AiSessionSummary summary) async {
    final res = requireSuccess(await _api.getAiSessionDetail(summary.id));
    final d = res.data;
    if (d is! Map) throw ApiException('Could not open this session.');
    return _toSession(Map<String, dynamic>.from(d), summary.request);
  }

  Future<void> startSession(int sessionId) async {
    requireSuccess(await _api.startAiSession(sessionId));
  }

  /// Marks one drill done; returns the points earned.
  Future<int> completeDrill(int sessionId, AiDrill drill) async {
    final res = requireSuccess(await _api.completeAiDrill(sessionId: sessionId, drillType: drill.type, drillId: drill.id));
    final d = res.data;
    return d is Map ? _i(d['points_earned']) : 0;
  }

  /// Marks the whole session done; returns the points earned for it.
  Future<int> completeSession(int sessionId) async {
    final res = requireSuccess(await _api.completeAiSession(sessionId));
    final d = res.data;
    return d is Map ? _i(d['points_earned']) : 0;
  }
}
