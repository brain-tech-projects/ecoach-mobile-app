import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Profile, My Skills, Notes, Chat and Notifications from the backend.
class ApiPlayerRepository implements PlayerRepository {
  ApiPlayerRepository(this._api, this._session);

  final ApiService _api;
  final SessionService _session;

  static int _id(String id) => int.tryParse(id) ?? 0;

  static DateTime _date(Object? v) =>
      DateTime.tryParse('${v ?? ''}')?.toLocal() ?? DateTime.now();

  static List<String> _strings(Object? v) =>
      v is List ? v.whereType<Object>().map((e) => e.toString()).toList() : <String>[];

  // ---- My Profile -------------------------------------------------------------

  Map<String, dynamic> _profileJson = <String, dynamic>{};

  @override
  Future<PlayerProfile> fetchProfile() async {
    final res = requireSuccess(await _api.getProfile());
    final d = res.data;
    if (d is! Map) throw ApiException('Could not load your profile.');
    final j = _profileJson = Map<String, dynamic>.from(d);

    final biggest = _strings(j['biggest_difference']);
    final frequency = _strings(j['training_frequency']);
    return PlayerProfile(
      profileName: (j['nickname'] ?? '').toString(),
      fullName: (j['full_name'] ?? '').toString(),
      parentEmail: (j['parent_guardian_email'] ?? j['email'] ?? '').toString(),
      countryCode: (j['country_code'] ?? 'ZW').toString(),
      club: (j['my_club'] ?? '').toString(),
      favouritePosition: (j['my_position'] ?? '').toString(),
      favouriteTeam: (j['my_fav_club'] ?? '').toString(),
      age: j['age'] is int ? j['age'] as int : int.tryParse('${j['age'] ?? ''}'),
      positions: _strings(j['playing_position']),
      levels: _strings(j['skill_level']),
      improve: _strings(j['improve_areas']),
      biggestDifference: biggest.isEmpty ? null : biggest.first,
      frequency: frequency.isEmpty ? null : frequency.first,
      dateOfBirth: DateTime.tryParse('${j['dob'] ?? ''}'),
      photoUrl: Env.skillMediaUrl(j['profile_photo'] as String?),
    );
  }

  @override
  Future<void> updateProfile(PlayerProfile p) async {
    String two(int v) => v.toString().padLeft(2, '0');
    final dob = p.dateOfBirth;
    final j = _profileJson;

    final res = requireSuccess(
      await _api.updateProfile(<String, dynamic>{
        'id': j['id'],
        'nickname': p.profileName,
        'full_name': p.fullName,
        'email': j['email'],
        'role': j['role'],
        'my_club': p.club,
        'my_position': p.favouritePosition,
        'my_fav_club': p.favouriteTeam,
        if (dob != null) 'dob': '${dob.year}-${two(dob.month)}-${two(dob.day)}',
        if (p.age != null) 'age': p.age,
        'playing_position': p.positions,
        'skill_level': p.levels,
        'improve_areas': p.improve,
        'biggest_difference': <String>[
          if (p.biggestDifference != null) p.biggestDifference!,
        ],
        'training_frequency': <String>[
          if (p.frequency != null) p.frequency!,
        ],
        'country': ProfileOptions.countries[p.countryCode] ?? j['country'],
        'country_code': p.countryCode,
        'parent_guardian_email': p.parentEmail,
      }),
    );

    // Keep the name shown in the header / menu up to date.
    final user = res.data;
    if (user is Map) {
      await _session.updateUser(
        UserModel.fromJson(Map<String, dynamic>.from(user)),
      );
    }
  }

  // ---- My Skills --------------------------------------------------------------

  @override
  Future<List<SavedSkill>> fetchSavedSkills() async {
    final res = requireSuccess(await _api.getFavourites());
    final d = res.data;
    final skills = d is Map ? d['skills'] : null;
    if (skills is! List) return const <SavedSkill>[];
    return <SavedSkill>[
      for (final e in skills.whereType<Map>())
        SavedSkill(
          // It is in My Skills, so the menu offers "Remove".
          drill: Drill.fromJson(
            Map<String, dynamic>.from(e),
          ).copyWith(canAddToMySkills: false),
        ),
    ];
  }

  @override
  Future<void> removeSavedSkill(int drillId) async {
    requireSuccess(await _api.setVideoInMySkills(drillId, add: false));
  }

  // ---- Notes ------------------------------------------------------------------

  @override
  Future<List<NoteNode>> fetchSkillNotes() async {
    final res = requireSuccess(await _api.getAllSkillNotes());
    final d = res.data;
    if (d is! List) return const <NoteNode>[];

    return <NoteNode>[
      for (final area in d.whereType<Map>())
        NoteNode(
          id: 'skill-type:${area['skill_type_id']}',
          title: (area['skill_type_name'] ?? '').toString(),
          thumbnail: Env.skillMediaUrl(area['skill_type_image'] as String?),
          children: <NoteNode>[
            for (final v in (area['videos'] is List ? area['videos'] as List : const []).whereType<Map>())
              NoteNode(
                id: 'drill:${v['skill_video_id']}',
                title: (v['skill_video_title'] ?? '').toString(),
                thumbnail: Env.skillMediaUrl(v['skill_video_image'] as String?),
                notes: _entries(v['notes'], prefix: ''),
              ),
          ],
        ),
    ];
  }

  @override
  Future<List<NoteNode>> fetchChallengeNotes() async {
    final res = requireSuccess(await _api.getAllChallengeNotes());
    final d = res.data;
    if (d is! List) return const <NoteNode>[];

    return <NoteNode>[
      for (final c in d.whereType<Map>())
        NoteNode(
          id: 'challenge:${c['challenge_id']}',
          title: (c['challenge_name'] ?? '').toString(),
          thumbnail: Env.skillMediaUrl(c['challenge_image'] as String?),
          notes: _entries(c['notes'], prefix: 'challenge:'),
        ),
    ];
  }

  static List<NoteEntry> _entries(Object? notes, {required String prefix}) =>
      notes is List
      ? <NoteEntry>[
          for (final n in notes.whereType<Map>())
            NoteEntry(
              id: '$prefix${n['id']}',
              text: (n['note'] ?? '').toString(),
              date: _date(n['created_at']),
            ),
        ]
      : const <NoteEntry>[];

  @override
  Future<void> deleteNote(String noteId) async {
    requireSuccess(await _api.deleteSkillNote(_id(noteId)));
  }

  // ---- Chat -------------------------------------------------------------------

  ChatMessage _message(Map<dynamic, dynamic> m) => ChatMessage(
    id: '${m['id']}',
    text: (m['message'] ?? '').toString(),
    sentAt: _date(m['created_at']),
    mine: '${m['sender_id']}' == '${_session.user.value?.id}',
    status: m['read_at'] == null ? MessageStatus.sent : MessageStatus.seen,
  );

  @override
  Future<List<ChatMessage>> fetchMessages(String coachId) async {
    final res = requireSuccess(await _api.openChat(_id(coachId)));
    final d = res.data;
    if (d is! List) return const <ChatMessage>[];
    return <ChatMessage>[for (final m in d.whereType<Map>()) _message(m)];
  }

  @override
  Future<ChatMessage> sendMessage(String coachId, String text) async {
    final res = requireSuccess(await _api.sendChatMessage(_id(coachId), text));
    final d = res.data;
    if (d is Map) return _message(d);
    return ChatMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      sentAt: DateTime.now(),
      mine: true,
    );
  }

  // ---- Notifications ----------------------------------------------------------

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final res = requireSuccess(await _api.getNotifications());
    final d = res.data;
    if (d is! List) return const <AppNotification>[];

    NotificationKind kind(Object? type) {
      final t = '${type ?? ''}'.toLowerCase();
      if (t.contains('skill')) return NotificationKind.skillVideo;
      if (t.contains('quiz')) return NotificationKind.quiz;
      return NotificationKind.other;
    }

    return <AppNotification>[
      for (final n in d.whereType<Map>())
        AppNotification(
          id: '${n['id']}',
          kind: kind(n['redirect_type']),
          title: (n['title'] ?? '').toString(),
          body: (n['description'] ?? '').toString(),
          createdAt: _date(n['created_at']),
        ),
    ];
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _api.markAllNotificationsRead();
  }
}
