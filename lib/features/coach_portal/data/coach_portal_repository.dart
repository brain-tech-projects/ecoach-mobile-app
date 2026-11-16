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

  static const List<String> seasons = <String>['Season 2026/27', 'Season 2025/26', 'Season 2024/25', 'Season 2023/24', 'Season 2022/23'];

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
          imageUrl: Env.mediaUrl(t['image'] as String?),
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

  Future<List<CoachPlayer>> fetchPlayers({bool force = false}) async {
    final res = requireSuccess(await _api.getCoachPlayers());
    final d = res.data;
    final list = d is Map ? _maps(d['players']) : <Map<String, dynamic>>[];
    return <CoachPlayer>[
      for (final p in list)
        if (_isConnected(p))
          CoachPlayer(
            id: _int(p['id']),
            name: _str(p['full_name']).isNotEmpty ? _str(p['full_name']) : _str(p['nickname']),
            subtitle: <String>[_str(p['my_position']), _str(p['my_club'])].where((e) => e.isNotEmpty).join(' . '),
            photoUrl: Env.skillMediaUrl(p['profile_photo'] as String?),
            countryCode: p['country_code'] as String?,
          ),
    ];
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
  Future<void> invitePlayer(String email) async => throw ApiException('Inviting players is not available yet.');

  Future<void> disconnectPlayer(int playerId) async => throw ApiException('Disconnecting players is not available yet.');

  // ---- Invitations (TODO(api): no endpoints yet) ------------------------------

  Future<List<PlayerInvitation>> fetchInvitations() async => const <PlayerInvitation>[];

  Future<void> respondInvitation(int id, {required bool accept}) async => throw ApiException('Not available yet.');

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

  // ---- Coaches summary (TODO(api): no endpoint yet) ---------------------------

  Future<List<SummaryRow>> fetchSummary(String season) async => const <SummaryRow>[];

  // ---- Programs ---------------------------------------------------------------

  Future<List<TrainingProgram>> fetchPrograms() async {
    final res = requireSuccess(await _api.getCoachTrainings());
    return <TrainingProgram>[
      for (final t in _maps(res.data))
        TrainingProgram(id: _int(t['id']), title: _str(t['training_name']), playerIds: <int>[for (final p in _maps(t['assigned_players'])) _int(p['id'])]),
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

  /// update-training needs the whole record, so the current one is read first.
  Future<void> renameProgram(int id, String title) async {
    final d = requireSuccess(await _api.getTrainingDetail(id)).data;
    if (d is! Map) throw ApiException('Could not load the program.');
    final fields = <String, dynamic>{};
    for (final k in const <String>['id', 'coach_id', 'type', 'skill_type_id', 'skill_video_id', 'description', 'video_path', 'video_title', 'video_description', 'status']) {
      if (d[k] != null) fields[k] = d[k];
    }
    fields['training_name'] = title;
    requireSuccess(await _api.updateTraining(fields));
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
