import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// In-memory demo data. A singleton, so removals / notes / messages persist
/// between pages while the app runs.
class DummyPlayerRepository implements PlayerRepository {
  static const String _video =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const String _img = 'assets/images/player';

  PlayerProfile _profile = const PlayerProfile(
    profileName: 'Virat',
    fullName: 'Vikash Singh',
    parentEmail: 'vikash@braintechnosys.com',
    countryCode: 'ZW',
    club: 'Cricket',
    favouritePosition: 'First',
    favouriteTeam: 'RCB',
    age: 6,
    positions: <String>['Defender', 'Goalkeeper'],
    levels: <String>['Just starting out', 'Confident player'],
    improve: <String>['Dribbling', 'Passing'],
    frequency: '2× a week',
    dateOfBirth: null,
    photoAsset: '$_img/profile_avatar.png',
  );

  final List<SavedSkill> _skills = <SavedSkill>[
    const SavedSkill(
      drill: Drill(
        id: 501,
        title: '#5 Step Overs (Stronger Foot)',
        description: 'Top Tip: Stay balanced  Focus: Dribbling Equipment: '
            'Football This is a great skill to build coordination, ball '
            'control, and confidence with the ball. Swing your dominant foot '
            'in a circle around the front of the ball. Land the foot next to '
            'the ball.',
        thumbnail: '$_img/skill_step_overs.png',
        videoUrl: _video,
        points: 5,
      ),
    ),
    const SavedSkill(
      drill: Drill(
        id: 502,
        title: '#5 Step Overs (stronger foot)',
        description: 'Top Tip: Stay balanced  Focus: Dribbling Equipment: Football',
        thumbnail: '',
        videoUrl: _video,
        points: 5,
      ),
    ),
  ];

  late final List<NoteNode> _skillNotes = <NoteNode>[
    NoteNode(
      id: 'area-dribbling',
      title: 'Dribbling',
      thumbnail: '$_img/skill_dribbling.png',
      children: <NoteNode>[
        NoteNode(
          id: 'drill-dribble-turn',
          title: '#8 Dribble and Turn',
          thumbnail: '$_img/skill_dribble_turn.png',
          notes: <NoteEntry>[
            NoteEntry(id: 'n1', text: 'test', date: DateTime(2026, 11, 3)),
          ],
        ),
      ],
    ),
  ];

  late final List<ChatMessage> _messages = _seedMessages();

  List<ChatMessage> _seedMessages() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    DateTime at(int h, int m) => DateTime(y.year, y.month, y.day, h, m);
    return <ChatMessage>[
      ChatMessage(id: 'm1', text: 'Hi', sentAt: at(15, 35), mine: false),
      ChatMessage(id: 'm2', text: 'kya', sentAt: at(15, 39), mine: true, status: MessageStatus.seen),
      ChatMessage(id: 'm3', text: 'kuch nq', sentAt: at(15, 40), mine: false),
      ChatMessage(id: 'm4', text: 'kya kuch na', sentAt: at(15, 40), mine: true, status: MessageStatus.seen),
      ChatMessage(id: 'm5', text: 'hi', sentAt: at(16, 13), mine: true, status: MessageStatus.seen),
      ChatMessage(id: 'm6', text: 'hhi', sentAt: at(16, 13), mine: false),
      ChatMessage(id: 'm7', text: 'hi', sentAt: at(16, 22), mine: true),
    ];
  }

  late final List<AppNotification> _notifications = _seedNotifications();

  List<AppNotification> _seedNotifications() {
    final n = DateTime.now();
    AppNotification skill(String id, String name, int hours) => AppNotification(
          id: id,
          kind: NotificationKind.skillVideo,
          title: 'Skill Video Completed',
          body: "You completed '$name' and earned 5 points!",
          createdAt: n.subtract(Duration(hours: hours)),
        );
    AppNotification quiz(String id, int hours) => AppNotification(
          id: id,
          kind: NotificationKind.quiz,
          title: 'Quiz Completed',
          body: 'You completed the quiz: World Cup Quiz',
          createdAt: n.subtract(Duration(hours: hours)),
        );
    return <AppNotification>[
      skill('a1', '#9 Step overs (weaker foot)', 3),
      skill('a2', 'Maradona 7', 4),
      skill('a3', '#5 Step Overs (Stronger Foot)', 5),
      quiz('a4', 6),
      quiz('a5', 6),
      skill('a6', '#5 Step Overs (Stronger Foot)', 6),
    ];
  }

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<PlayerProfile> fetchProfile() async => _profile;

  @override
  Future<void> updateProfile(PlayerProfile profile) async {
    await _latency();
    _profile = profile;
  }

  @override
  Future<List<SavedSkill>> fetchSavedSkills() async => List<SavedSkill>.of(_skills);

  @override
  Future<void> removeSavedSkill(int drillId) async {
    await _latency();
    _skills.removeWhere((s) => s.drill.id == drillId);
  }

  @override
  Future<List<NoteNode>> fetchSkillNotes() async => List<NoteNode>.of(_skillNotes);

  List<NoteNode> _without(List<NoteNode> nodes, String noteId) => <NoteNode>[
        for (final n in nodes)
          NoteNode(
            id: n.id,
            title: n.title,
            thumbnail: n.thumbnail,
            notes: n.notes.where((e) => e.id != noteId).toList(),
            children: _without(n.children, noteId),
          ),
      ];

  @override
  Future<void> deleteNote(String noteId) async {
    await _latency();
    final s = _without(_skillNotes, noteId);
    _skillNotes
      ..clear()
      ..addAll(s);
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String coachId) async =>
      List<ChatMessage>.of(_messages);

  @override
  Future<ChatMessage> sendMessage(String coachId, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final m = ChatMessage(
      id: 'm${_messages.length + 1}',
      text: text,
      sentAt: DateTime.now(),
      mine: true,
    );
    _messages.add(m);
    return m;
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async =>
      List<AppNotification>.of(_notifications);
}
