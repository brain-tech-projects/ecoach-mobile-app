import 'package:get/get.dart';

import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

/// Registers the shared repository once (call from every coach binding).
void ensureCoachPortalRepository() {
  if (!Get.isRegistered<CoachPortalRepository>()) {
    Get.put<CoachPortalRepository>(CoachPortalRepository(), permanent: true);
  }
}

/// DUMMY in-memory data source. Keep the method signatures and swap the
/// bodies for real API calls later; controllers/UI need no change.
class CoachPortalRepository {
  static const String _sampleVideo = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const List<String> seasons = <String>['Season 2026/27', 'Season 2025/26', 'Season 2024/25', 'Season 2023/24', 'Season 2022/23'];

  int _id = 100;
  int _next() => ++_id;
  Future<void> _lag() => Future<void>.delayed(const Duration(milliseconds: 250));

  final List<CoachPlayer> _players = <CoachPlayer>[
    const CoachPlayer(id: 140, name: 'Prescott Skinner', countryCode: 'GB'),
    const CoachPlayer(id: 141, name: 'Aarav Mehta', subtitle: 'Midfielder . Delhi FC', countryCode: 'IN'),
    const CoachPlayer(id: 142, name: 'Liam Carter', subtitle: 'Striker . Austin United', countryCode: 'US'),
  ];

  final List<CoachTeam> _teams = <CoachTeam>[
    const CoachTeam(id: 1, name: 'CSK', description: 'CSK is a very good team', groups: <TeamGroup>[TeamGroup(id: 1, name: 'TeamA', playerIds: <int>[140])]),
  ];

  final List<TrainingProgram> _programs = <TrainingProgram>[
    const TrainingProgram(id: 1, title: '#29 Vertical Throw, Knee & Trap'),
  ];

  final List<PlayerInvitation> _invitations = <PlayerInvitation>[];

  final Map<int, List<ChatMessage>> _chats = <int, List<ChatMessage>>{
    140: <ChatMessage>[
      ChatMessage(id: 1, text: 'hi', time: DateTime(2026, 10, 9, 12, 25), mine: true, seen: true),
      ChatMessage(id: 2, text: 'Hello', time: DateTime(2026, 10, 9, 12, 27), mine: true, seen: true),
      ChatMessage(id: 3, text: 'Hi', time: DateTime(2026, 10, 9, 12, 38), mine: true, seen: true),
      ChatMessage(id: 4, text: 'Hello', time: DateTime(2026, 10, 9, 13, 6), mine: false),
      ChatMessage(id: 5, text: 'aaa', time: DateTime(2026, 10, 9, 13, 6), mine: true, seen: true),
      ChatMessage(id: 6, text: '00000', time: DateTime(2026, 10, 9, 13, 16), mine: true, seen: true),
      ChatMessage(id: 7, text: 'Hi', time: DateTime(2026, 10, 12, 12, 59), mine: false),
    ],
  };

  static const String _img = 'assets/images/skills/';

  final List<SkillItem> _skills = const <SkillItem>[
    SkillItem(id: 1, name: 'Dribbling', imageUrl: '${_img}dribbling.jpg', drills: <DrillItem>[
      DrillItem(id: 5, title: '#5 Step Overs (Stronger Foot)', videoUrl: _sampleVideo),
      DrillItem(id: 8, title: '#8 Dribble and Turn', videoUrl: _sampleVideo),
      DrillItem(id: 9, title: '#9 Step overs (weaker foot)', videoUrl: _sampleVideo),
      DrillItem(id: 11, title: '#11 Inside Foot Dribble', videoUrl: _sampleVideo),
      DrillItem(id: 12, title: '#12 Dribbling: Inside to outside', videoUrl: _sampleVideo),
      DrillItem(id: 13, title: '#13 Step Overs: Changing Feet', videoUrl: _sampleVideo),
      DrillItem(id: 15, title: '#15 Step Overs', videoUrl: _sampleVideo),
    ]),
    SkillItem(id: 2, name: 'Ball Mastery', imageUrl: '${_img}ball_mastery.jpg', drills: <DrillItem>[
      DrillItem(id: 21, title: '#21 Sole Rolls', videoUrl: _sampleVideo),
      DrillItem(id: 22, title: '#22 Toe Taps', videoUrl: _sampleVideo),
    ]),
    SkillItem(id: 3, name: 'Fitness', imageUrl: '${_img}fitness.jpg', drills: <DrillItem>[
      DrillItem(id: 31, title: '#31 Agility Ladder', videoUrl: _sampleVideo),
    ]),
    SkillItem(id: 4, name: 'Ball Control', imageUrl: '${_img}ball_control.jpg', drills: <DrillItem>[
      DrillItem(id: 29, title: '#29 Vertical Throw, Knee & Trap', videoUrl: _sampleVideo),
      DrillItem(id: 30, title: '#30 Thigh Control & Pass', videoUrl: _sampleVideo),
    ]),
    SkillItem(id: 5, name: 'Tricks', imageUrl: '${_img}tricks.jpg', drills: <DrillItem>[
      DrillItem(id: 41, title: '#41 Rainbow Flick', videoUrl: _sampleVideo),
    ]),
  ];

  // ---- Home ----
  Future<CoachHomeStats> fetchHome() async {
    await _lag();
    return CoachHomeStats(teams: _teams.length, trainings: _programs.length, players: _players.length);
  }

  // ---- Teams ----
  Future<List<CoachTeam>> fetchTeams() async {
    await _lag();
    return List<CoachTeam>.of(_teams);
  }

  Future<void> saveTeam({int? id, required String name, required String description, String? imagePath}) async {
    await _lag();
    if (id == null) {
      _teams.add(CoachTeam(id: _next(), name: name, description: description, imageUrl: imagePath));
    } else {
      final i = _teams.indexWhere((t) => t.id == id);
      if (i >= 0) _teams[i] = _teams[i].copyWith(name: name, description: description, imageUrl: imagePath);
    }
  }

  Future<void> deleteTeam(int id) async {
    await _lag();
    _teams.removeWhere((t) => t.id == id);
  }

  Future<void> createGroup(int teamId, String name, List<int> playerIds) async {
    await _lag();
    final i = _teams.indexWhere((t) => t.id == teamId);
    if (i < 0) return;
    _teams[i] = _teams[i].copyWith(groups: <TeamGroup>[..._teams[i].groups, TeamGroup(id: _next(), name: name, playerIds: playerIds)]);
  }

  Future<void> deleteGroup(int groupId) async {
    await _lag();
    for (var i = 0; i < _teams.length; i++) {
      _teams[i] = _teams[i].copyWith(groups: _teams[i].groups.where((g) => g.id != groupId).toList());
    }
  }

  Future<void> addPlayersToTeam(int teamId, List<int> playerIds) async => _lag();

  // ---- Players ----
  Future<List<CoachPlayer>> fetchPlayers({bool force = false}) async {
    await _lag();
    return List<CoachPlayer>.of(_players);
  }

  Future<PlayerStats> fetchPlayerStats(int playerId) async {
    await _lag();
    final k = playerId % 10;
    return playerId == 140 ? const PlayerStats() : PlayerStats(sessions: k + 3, skills: k + 6, quizzes: k, tracker: k + 1);
  }

  Future<void> invitePlayer(String email) async => _lag();

  Future<void> disconnectPlayer(int playerId) async {
    await _lag();
    _players.removeWhere((p) => p.id == playerId);
  }

  Future<void> notifyPlayers({required List<int> playerIds, required String title, required String description}) async => _lag();

  // ---- Invitations ----
  Future<List<PlayerInvitation>> fetchInvitations() async {
    await _lag();
    return List<PlayerInvitation>.of(_invitations);
  }

  Future<void> respondInvitation(int id, {required bool accept}) async {
    await _lag();
    final i = _invitations.indexWhere((e) => e.id == id);
    if (i < 0) return;
    if (accept) _players.add(_invitations[i].player);
    _invitations.removeAt(i);
  }

  // ---- Chats ----
  Future<List<ChatMessage>> fetchMessages(int playerId) async {
    await _lag();
    return List<ChatMessage>.of(_chats[playerId] ?? const <ChatMessage>[]);
  }

  Future<ChatMessage> sendMessage(int playerId, String text) async {
    final msg = ChatMessage(id: _next(), text: text, time: DateTime.now(), mine: true);
    (_chats[playerId] ??= <ChatMessage>[]).add(msg);
    return msg;
  }

  // ---- Coaches summary ----
  Future<List<SummaryRow>> fetchSummary(String season) async {
    await _lag();
    final older = season != seasons.first;
    return <SummaryRow>[
      for (final p in _players)
        SummaryRow(
          player: p,
          values: (older || p.id != 140) ? List<int>.generate(12, (i) => ((p.id + i * 3) % 9) + (older ? 2 : 0)) : List<int>.filled(12, 0),
          allocatedCompleted: older && p.id != 140,
        ),
    ];
  }

  // ---- Programs ----
  Future<List<TrainingProgram>> fetchPrograms() async {
    await _lag();
    return List<TrainingProgram>.of(_programs);
  }

  Future<void> createEcoachProgram(int skillVideoId) async {
    await _lag();
    final d = _skills.expand((s) => s.drills).firstWhere((e) => e.id == skillVideoId);
    _programs.add(TrainingProgram(id: _next(), title: d.title));
  }

  /// [onProgress] gets 0.0..1.0 while uploading (simulated here).
  Future<void> createOwnProgram({required String title, String description = '', required String videoPath, void Function(double)? onProgress}) async {
    for (var i = 0; i <= 10; i++) {
      onProgress?.call(i / 10);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    _programs.add(TrainingProgram(id: _next(), title: title));
  }

  Future<void> renameProgram(int id, String title) async {
    await _lag();
    final i = _programs.indexWhere((p) => p.id == id);
    if (i >= 0) _programs[i] = TrainingProgram(id: id, title: title, playerIds: _programs[i].playerIds);
  }

  Future<void> deleteProgram(int id) async {
    await _lag();
    _programs.removeWhere((p) => p.id == id);
  }

  Future<void> addPlayersToProgram(int programId, List<int> playerIds) async {
    await _lag();
    final i = _programs.indexWhere((p) => p.id == programId);
    if (i >= 0) {
      _programs[i] = TrainingProgram(id: programId, title: _programs[i].title, playerIds: <int>{..._programs[i].playerIds, ...playerIds}.toList());
    }
  }

  // ---- eCoach skill library ----
  Future<List<SkillItem>> fetchSkillCategories() async {
    await _lag();
    return _skills;
  }
}
