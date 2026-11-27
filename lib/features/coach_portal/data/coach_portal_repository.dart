import 'package:ecoach_pro/features/coach_portal/data/coach_sync.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:get/get.dart';

import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

/// Registers the shared repository once (call from every coach binding).
void ensureCoachPortalRepository() {
  if (!Get.isRegistered<CoachPortalRepository>()) {
    Get.put<CoachPortalRepository>(CoachPortalRepository(), permanent: true);
  }
}

/// Coach portal data source. Talks to the backend through [ApiService] only
/// and never touches player code. Method signatures are the ones the
/// controllers already use.
///
/// NOT in the coach API list yet (so not connected, see the `TODO(api)`s):
/// invite player, invitations list / accept / reject, disconnect player,
/// coaches summary.
class CoachPortalRepository {
  CoachPortalRepository({ApiService? api, SessionService? session})
    : _api = api ?? Get.find<ApiService>(),
      _session = session ?? Get.find<SessionService>();

  final ApiService _api;
  final SessionService _session;

  /// Current season first (seasons start in July), then the four before it.
  static List<String> get seasons {
    final now = DateTime.now();
    final start = now.month >= 7 ? now.year : now.year - 1;
    String label(int y) => 'Season $y/${((y + 1) % 100).toString().padLeft(2, '0')}';
    return <String>[for (var i = 0; i < 5; i++) label(start - i)];
  }

  /// "Season 2026/27" -> (2026, 2027).
  static ({int start, int end}) _seasonYears(String season) {
    final m = RegExp(r'(\d{4})').firstMatch(season);
    final start = int.tryParse(m?.group(1) ?? '') ?? DateTime.now().year;
    return (start: start, end: start + 1);
  }

  static const int _partSize = 10 * 1024 * 1024; // S3 min part = 5MB (last may be smaller)

  // ---- helpers ----------------------------------------------------------------

  static int _int(Object? v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

  static String _str(Object? v) => (v ?? '').toString();

  static List<Map<String, dynamic>> _maps(Object? v) => v is List ? <Map<String, dynamic>>[for (final e in v.whereType<Map>()) Map<String, dynamic>.from(e)] : <Map<String, dynamic>>[];

  int get _coachId => _session.user.value?.id ?? 0;

  // ---- Home -------------------------------------------------------------------

  Future<CoachHomeStats> fetchHome() async {
    final d = requireSuccess(await _api.getCoachDashboard()).data;
    final j = d is Map ? d : const <String, dynamic>{};
    return CoachHomeStats(teams: _int(j['teamsCount']), trainings: _int(j['trainingsCount']), players: _int(j['playersCount']));
  }

  // ---- Teams ------------------------------------------------------------------

  /// The API identifies a group by (team, name) only; the UI wants an int id.
  /// These are handed out while parsing and resolved again in [deleteGroup].
  final Map<int, ({int teamId, String name})> _groupRefs = <int, ({int teamId, String name})>{};
  int _groupSeq = 0;

  Future<List<CoachTeam>> fetchTeams() async {
    final res = requireSuccess(await _api.getCoachTeams());
    _groupRefs.clear();
    return <CoachTeam>[
      for (final t in _maps(res.data))
        CoachTeam(
          id: _int(t['id']),
          name: _str(t['team_name']),
          description: _str(t['description']),
          // Same disk as profile photos first, the Laravel storage as backup.
          imageUrl: Env.skillMediaUrl(t['image'] as String?),
          imageAltUrl: Env.mediaUrl(t['image'] as String?),
          groups: <TeamGroup>[
            for (final g in _maps(t['groups']))
              () {
                final id = ++_groupSeq;
                final name = _str(g['group_name']);
                _groupRefs[id] = (teamId: _int(t['id']), name: name);
                return TeamGroup(id: id, name: name, playerIds: <int>[for (final p in _maps(g['players'])) _int(p['id'])]);
              }(),
          ],
        ),
    ];
  }

  Future<void> saveTeam({int? id, required String name, required String description, String? imagePath}) async {
    final res = id == null
        ? await _api.storeTeam(name: name, description: description, imagePath: imagePath)
        : await _api.updateTeam(id: id, coachId: _coachId, name: name, description: description, imagePath: imagePath);
    requireSuccess(res);
  }

  Future<void> deleteTeam(int id) async {
    requireSuccess(await _api.deleteTeam(id));
  }

  /// Creates the group, or replaces its players when the name already exists.
  Future<void> createGroup(int teamId, String name, List<int> playerIds) async {
    requireSuccess(await _api.assignTeamPlayers(teamId: teamId, playerIds: playerIds, groupName: name));
  }

  Future<void> deleteGroup(int groupId) async {
    final ref = _groupRefs[groupId];
    if (ref == null) throw ApiException('Group not found. Please refresh and try again.');
    requireSuccess(await _api.deleteTeamGroup(ref.teamId, ref.name));
  }

  // ---- Players ----------------------------------------------------------------

  List<Map<String, dynamic>>? _teamRows;
  DateTime? _teamRowsAt;
  int _teamRowsRevision = -1;

  /// One `my-team` call shared by Players + Invitations (8 s cache, dropped on any coach change).
  Future<List<Map<String, dynamic>>> _myTeamRows({bool force = false}) async {
    final fresh = !force &&
        _teamRows != null &&
        _teamRowsAt != null &&
        _teamRowsRevision == CoachSync.revision.value &&
        DateTime.now().difference(_teamRowsAt!) < const Duration(seconds: 8);
    if (fresh) return _teamRows!;
    final res = requireSuccess(await _api.getCoachPlayers());
    final d = res.data;
    _teamRows = d is Map ? _maps(d['players']) : <Map<String, dynamic>>[];
    _teamRowsAt = DateTime.now();
    _teamRowsRevision = CoachSync.revision.value;
    return _teamRows!;
  }

  CoachPlayer _player(Map<String, dynamic> p) => CoachPlayer(
    id: _int(p['id']),
    name: _str(p['full_name']).isNotEmpty ? _str(p['full_name']) : _str(p['nickname']),
    subtitle: <String>[_str(p['my_position']), _str(p['my_club'])].where((e) => e.isNotEmpty).join(' . '),
    photoUrl: Env.skillMediaUrl(p['profile_photo'] as String?),
    countryCode: p['country_code'] as String?,
    email: _str(p['email']),
  );

  Future<List<CoachPlayer>> fetchPlayers({bool force = false}) async {
    final rows = await _myTeamRows(force: force);
    return <CoachPlayer>[for (final p in rows) if (_isConnected(p)) _player(p)];
  }

  static String _invStatus(Map<String, dynamic> p) {
    final inv = p['invitation'];
    return inv is Map ? _str(inv['status']).toLowerCase() : '';
  }

  /// Accepted and not left. Players without invitation data are kept.
  static bool _isConnected(Map<String, dynamic> p) {
    final inv = p['invitation'];
    if (inv is! Map) return true;
    return _str(inv['status']).toLowerCase() == 'accepted' && inv['lefted_at'] == null;
  }

  Future<PlayerStats> fetchPlayerStats(int playerId) async {
    final res = requireSuccess(await _api.getPlayerDetail(playerId));
    final b = res.body ?? const <String, dynamic>{};
    return PlayerStats(sessions: _int(b['sessionsCompleted']), skills: _int(b['skillsAttempted']), quizzes: _int(b['quizzesTaken']), tracker: _int(b['trackerUpdates']));
  }

  Future<void> notifyPlayers({required List<int> playerIds, required String title, required String description}) async {
    // The API takes one player per call.
    await Future.wait(<Future<void>>[
      for (final id in playerIds)
        _api.notifyPlayer(playerId: id, title: title, description: description).then((r) {
          requireSuccess(r);
        }),
    ]);
  }

  // TODO(api): invite player / disconnect player endpoints are not in the list yet.
  /// Coach invites a player by e-mail. Duplicates (already on the team / invitation
  /// pending) are rejected before calling the API.
  Future<void> invitePlayer(String email) async {
    final e = email.trim().toLowerCase();
    final rows = await _myTeamRows(force: true);
    for (final p in rows) {
      if (_str(p['email']).toLowerCase() != e) continue;
      if (_isConnected(p) && p['invitation'] is Map) throw ApiException('This player is already on your team.');
      if (_invStatus(p) == 'pending') throw ApiException('An invitation to this player is already pending.');
    }
    requireSuccess(await _api.invitePlayer(e));
    _teamRows = null;
  }

  Future<void> disconnectPlayer(int playerId) async {
    requireSuccess(await _api.disconnectPlayer(playerId));
    _teamRows = null;
  }

  // ---- Invitations (pending rows of `my-team`) ----------------------------------

  /// Players currently connected to this coach (`my-connected-players`).
  Future<List<CoachPlayer>> fetchConnectedPlayers() async {
    final res = requireSuccess(await _api.getMyConnectedPlayers());
    final d = res.data;
    return <CoachPlayer>[
      for (final p in _maps(d is Map ? d['connections'] : null))
        CoachPlayer(
          id: _int(p['player_id']),
          name: _str(p['full_name']),
          subtitle: <String>[_str(p['my_position']), _str(p['my_club'])].where((e) => e.isNotEmpty).join(' . '),
          photoUrl: Env.skillMediaUrl(p['profile_photo'] as String?),
        ),
    ];
  }

  /// Pending requests players sent to this coach (`my-invitations-coach`).
  Future<List<PlayerInvitation>> fetchInvitations() async {
    final res = requireSuccess(await _api.getMyInvitationsCoach());
    final d = res.data;
    return <PlayerInvitation>[
      for (final i in _maps(d is Map ? d['invitations'] : null))
        if (_str(i['status']).toLowerCase() == 'pending' && i['player'] is Map)
          PlayerInvitation(
            id: _int(i['id']),
            player: _player(Map<String, dynamic>.from(i['player'] as Map)),
          ),
    ];
  }

  Future<void> respondInvitation(int id, {required bool accept}) async {
    requireSuccess(await _api.respondPlayerInvitation(id, accept: accept));
    _teamRows = null;
  }

  // ---- Chats (same chat endpoints the player app uses; sender = signed-in coach)

  Future<List<ChatMessage>> fetchMessages(int playerId) async {
    final res = requireSuccess(await _api.openChat(playerId));
    final d = res.data;
    if (d is! List) return const <ChatMessage>[];
    return <ChatMessage>[for (final m in d.whereType<Map>()) _message(m)];
  }

  Future<ChatMessage> sendMessage(int playerId, String text) async {
    final res = requireSuccess(await _api.sendChatMessage(playerId, text));
    final d = res.data;
    if (d is Map) return _message(d);
    return ChatMessage(id: DateTime.now().microsecondsSinceEpoch, text: text, time: DateTime.now(), mine: true);
  }

  ChatMessage _message(Map<dynamic, dynamic> m) => ChatMessage(
    id: _int(m['id']),
    text: _str(m['message']),
    time: DateTime.tryParse(_str(m['created_at']))?.toLocal() ?? DateTime.now(),
    mine: '${m['sender_id']}' == '$_coachId',
    seen: m['read_at'] != null,
  );

  // ---- Coaches summary ---------------------------------------------------------

  Future<List<SummaryRow>> fetchSummary(String season) async {
    final y = _seasonYears(season);
    final res = requireSuccess(await _api.getCoachSummary(y.start, y.end));
    int n(Map<String, dynamic> m, String k) => _int(m[k]);
    return <SummaryRow>[
      for (final r in _maps(res.data))
        SummaryRow(
          player: CoachPlayer(
            id: _int(r['player_id']),
            name: _str(r['full_name']).isNotEmpty ? _str(r['full_name']) : _str(r['nickname']),
            subtitle: <String>[_str(r['my_position']), _str(r['my_club'])].where((e) => e.isNotEmpty).join(' . '),
            photoUrl: Env.skillMediaUrl((r['avatar'] ?? r['profile_photo']) as String?),
            countryCode: r['country_code'] as String?,
          ),
          // Skills, Sessions, Training, Quizzes, Tracker, AI Sessions (all time, last 7 days)
          values: <int>[
            n(r, 'skill_completed_all_time'), n(r, 'skill_completed_last_seven_days'),
            n(r, 'session_completed_all_time'), n(r, 'session_completed_last_seven_days'),
            n(r, 'allocated_training_all_time'), n(r, 'allocated_training_last_seven_days'),
            n(r, 'quizzes_taken_all_time'), n(r, 'quizzes_taken_last_seven_days'),
            n(r, 'tracker_updates_all_time'), n(r, 'tracker_updates_last_seven_days'),
            n(r, 'ai_sessions_all_time'), n(r, 'ai_sessions_last_seven_days'),
          ],
          allocatedCompleted: r['is_all_training_completed'] == true,
        ),
    ];
  }

  /// History behind one Coaches Summary cell (`coach-summary-detail`).
  Future<SummaryDetail> fetchSummaryDetail({required int playerId, required SummaryDetailType type, required String season}) async {
    final y = _seasonYears(season);
    final res = requireSuccess(
      await _api.getCoachSummaryDetail(playerId: playerId, type: type.apiValue, startYear: y.start, endYear: y.end),
    );
    final d = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : const <String, dynamic>{};
    final p = d['player'];
    final h = d['history'] is Map ? Map<String, dynamic>.from(d['history'] as Map) : const <String, dynamic>{};
    List<SummaryHistoryItem> parse(Object? v) => <SummaryHistoryItem>[for (final m in _maps(v)) _historyItem(type, m)];
    return SummaryDetail(
      player: p is Map ? _player(Map<String, dynamic>.from(p)) : null,
      allTime: parse(h['all_time']),
      lastSevenDays: parse(h['last_seven_days']),
    );
  }

  static SummaryHistoryItem _historyItem(SummaryDetailType type, Map<String, dynamic> m) {
    final title = (switch (type) {
      SummaryDetailType.skill => _str(m['skill_name']),
      SummaryDetailType.session || SummaryDetailType.allocatedTraining => _str(m['training_name']),
      SummaryDetailType.quiz => _str(m['quiz_name']),
      SummaryDetailType.tracker => _str(m['opponent_team']).trim().isEmpty ? 'Match' : 'vs ${_str(m['opponent_team']).trim()}',
      SummaryDetailType.aiSessions => _str(m['request']),
    }).trim();
    return SummaryHistoryItem(
      title: title.isEmpty ? '-' : title,
      completedAt: _summaryTime(m['completed_at']),
      drills: type == SummaryDetailType.aiSessions
          ? <SummaryDrill>[
              for (final dr in _maps(m['drills']))
                SummaryDrill(title: _str(dr['title']), completed: dr['completed'] == true || dr['completed'] == 1),
            ]
          : const <SummaryDrill>[],
    );
  }

  /// "2026-11-20 09:53:46" is shown as sent; ISO UTC ("...Z") is shown in local time.
  static DateTime? _summaryTime(Object? v) {
    final t = DateTime.tryParse(_str(v).trim());
    if (t == null) return null;
    return t.isUtc ? t.toLocal() : t;
  }

  // ---- Programs ---------------------------------------------------------------

  Future<List<TrainingProgram>> fetchPrograms() async {
    final res = requireSuccess(await _api.getCoachTrainings());
    return <TrainingProgram>[
      for (final t in _maps(res.data))
        TrainingProgram(
          id: _int(t['id']),
          title: _str(t['training_name']),
          playerIds: <int>[for (final p in _maps(t['assigned_players'])) _int(p['id'])],
          type: _str(t['type']),
          description: _str(t['description']),
          videoPath: _str(t['video_path']),
          skillTypeId: int.tryParse('${t['skill_type_id'] ?? ''}'),
          skillVideoId: int.tryParse('${t['skill_video_id'] ?? ''}'),
        ),
    ];
  }

  /// eCoach library video -> new program.
  Future<void> createEcoachProgram(SkillItem category, DrillItem drill) async {
    requireSuccess(
      await _api.storeTraining(<String, dynamic>{
        'training_name': drill.title,
        'description': '',
        'video_path': drill.videoUrl,
        'video_title': drill.title,
        'video_description': '',
        'type': 'eCoach',
        'skill_type_id': category.id,
        'skill_video_id': drill.id,
      }),
    );
  }

  /// Coach's own video: multipart upload to S3, then the program is created
  /// with the public URL. [onProgress] gets 0.0..1.0 while uploading.
  Future<void> createOwnProgram({required String title, String description = '', required String videoPath, void Function(double)? onProgress}) async {
    final publicUrl = await _uploadVideo(videoPath, onProgress);
    requireSuccess(
      await _api.storeTraining(<String, dynamic>{
        'training_name': title,
        'description': description,
        'video_path': publicUrl,
        'video_title': '',
        'video_description': '',
        'type': 'own',
      }),
    );
    onProgress?.call(1);
  }

  Future<String> _uploadVideo(String path, void Function(double)? onProgress) async {
    final file = File(path);
    final total = await file.length();
    final init = requireSuccess(await _api.initiateVideoUpload(path.split('/').last)).data;
    if (init is! Map) throw ApiException('Could not start the video upload.');
    final uploadId = _str(init['upload_id']);
    final key = _str(init['key']);
    final fallbackUrl = _str(init['public_url']);

    final parts = <int, String>{};
    final raf = await file.open();
    try {
      final count = math.max(1, (total / _partSize).ceil());
      for (var n = 1; n <= count; n++) {
        // One URL per part, requested right before use (URLs expire in 30 min).
        final urlRes = requireSuccess(await _api.getVideoPartUrls(uploadId: uploadId, key: key, partNumbers: <int>[n])).data;
        final url = urlRes is List && urlRes.isNotEmpty && urlRes.first is Map ? _str((urlRes.first as Map)['url']) : '';
        if (url.isEmpty) throw ApiException('Could not get the upload link.');

        final offset = (n - 1) * _partSize;
        await raf.setPosition(offset);
        final Uint8List bytes = await raf.read(math.min(total - offset, _partSize));

        final etag = await _api.uploadVideoPart(url, bytes, onProgress: (sent, _) => onProgress?.call(((offset + sent) / total) * 0.95));
        if (etag == null) throw ApiException('Video upload failed. Please check your connection and try again.');
        parts[n] = etag;
      }
    } finally {
      await raf.close();
    }

    final done = requireSuccess(await _api.completeVideoUpload(uploadId: uploadId, key: key, parts: parts)).data;
    final url = done is Map ? _str(done['public_url']) : '';
    return url.isNotEmpty ? url : fallbackUrl;
  }

  /// Update Training with an eCoach library video.
  Future<void> updateEcoachProgram(TrainingProgram p, SkillItem category, DrillItem drill) async {
    requireSuccess(
      await _api.updateTraining(<String, dynamic>{
        'id': p.id,
        'coach_id': _coachId,
        'type': 'eCoach',
        'training_name': drill.title,
        'description': '',
        'video_path': drill.videoUrl,
        'video_title': drill.title,
        'video_description': '',
        'skill_type_id': category.id,
        'skill_video_id': drill.id,
        'status': 'Active',
      }),
    );
  }

  /// Update Training with the coach's own video. [newVideoPath] null keeps
  /// the video that is already stored.
  Future<void> updateOwnProgram(TrainingProgram p, {required String title, String description = '', String? newVideoPath, void Function(double)? onProgress}) async {
    final video = newVideoPath != null ? await _uploadVideo(newVideoPath, onProgress) : p.videoPath;
    if (video.isEmpty) throw ApiException('Please upload a training video.');
    requireSuccess(
      await _api.updateTraining(<String, dynamic>{
        'id': p.id,
        'coach_id': _coachId,
        'type': 'own',
        'training_name': title,
        'description': description,
        'video_path': video,
        'status': 'Active',
      }),
    );
    onProgress?.call(1);
  }

  Future<void> deleteProgram(int id) async {
    requireSuccess(await _api.deleteTraining(id));
  }

  Future<void> addPlayersToProgram(int programId, List<int> playerIds) async {
    requireSuccess(await _api.assignPlayersToTraining(programId, playerIds));
  }

  // ---- eCoach skill library ---------------------------------------------------

  /// Categories only; the videos load when one is picked ([fetchSkillDrills]).
  Future<List<SkillItem>> fetchSkillCategories() async {
    final res = requireSuccess(await _api.getProgramSkillTypes());
    return <SkillItem>[for (final s in _maps(res.data)) SkillItem(id: _int(s['id']), name: _str(s['name']), imageUrl: Env.skillMediaUrl(s['image'] as String?))];
  }

  Future<List<DrillItem>> fetchSkillDrills(int skillTypeId) async {
    final res = requireSuccess(await _api.getProgramSkillVideos(skillTypeId));
    return <DrillItem>[for (final v in _maps(res.data)) DrillItem(id: _int(v['id']), title: _str(v['title']), videoUrl: _str(v['video']))];
  }
}
