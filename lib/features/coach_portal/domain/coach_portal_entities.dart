/// UI-only models (dummy data for now; replace with API models later).
class CoachHomeStats {
  const CoachHomeStats({this.teams = 0, this.trainings = 0, this.players = 0});
  final int teams;
  final int trainings;
  final int players;
}

class CoachPlayer {
  const CoachPlayer({required this.id, required this.name, this.subtitle = '', this.photoUrl, this.countryCode, this.email = ''});
  final int id;
  final String name;
  final String subtitle;
  final String? photoUrl;
  final String? countryCode;
  final String email;
}

class PlayerStats {
  const PlayerStats({this.sessions = 0, this.skills = 0, this.quizzes = 0, this.tracker = 0});
  final int sessions;
  final int skills;
  final int quizzes;
  final int tracker;
}

class TeamGroup {
  const TeamGroup({required this.id, required this.name, this.playerIds = const <int>[]});
  final int id;
  final String name;
  final List<int> playerIds;
  int get playerCount => playerIds.length;
}

class CoachTeam {
  const CoachTeam({required this.id, required this.name, this.description = '', this.imageUrl, this.imageAltUrl, this.groups = const <TeamGroup>[]});
  final int id;
  final String name;
  final String description;

  /// http(s) URL or a local file path.
  final String? imageUrl;

  /// Same file on the other storage host, tried when [imageUrl] fails.
  final String? imageAltUrl;
  final List<TeamGroup> groups;

  CoachTeam copyWith({String? name, String? description, String? imageUrl, List<TeamGroup>? groups}) => CoachTeam(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    imageAltUrl: imageAltUrl,
    groups: groups ?? this.groups,
  );
}

class TrainingProgram {
  const TrainingProgram({
    required this.id,
    required this.title,
    this.playerIds = const <int>[],
    this.type = '',
    this.description = '',
    this.videoPath = '',
    this.skillTypeId,
    this.skillVideoId,
  });
  final int id;
  final String title;
  final List<int> playerIds;

  /// `eCoach` (library video) or `own` (uploaded by the coach).
  final String type;
  final String description;
  final String videoPath;
  final int? skillTypeId;
  final int? skillVideoId;
  int get playerCount => playerIds.length;
  bool get isEcoach => type.toLowerCase() == 'ecoach';
  bool get isOwn => type.toLowerCase() == 'own';
}

class SkillItem {
  const SkillItem({required this.id, required this.name, this.imageUrl, this.drills = const <DrillItem>[]});
  final int id;
  final String name;
  final String? imageUrl;
  final List<DrillItem> drills;
}

class DrillItem {
  const DrillItem({required this.id, required this.title, required this.videoUrl});
  final int id;
  final String title;
  final String videoUrl;
}

class ChatMessage {
  const ChatMessage({required this.id, required this.text, required this.time, required this.mine, this.seen = false});
  final int id;
  final String text;
  final DateTime time;
  final bool mine;
  final bool seen;
}

/// "09 Oct 2026, 12:25 pm"
String formatChatTime(DateTime t) {
  const m = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.day)} ${m[t.month - 1]} ${t.year}, ${two(h12)}:${two(t.minute)} ${t.hour >= 12 ? 'pm' : 'am'}';
}

class PlayerInvitation {
  const PlayerInvitation({required this.id, required this.player, this.incoming = true});
  final int id;
  final CoachPlayer player;

  /// true = the player asked to join (accept / reject); false = sent by this coach (waiting).
  final bool incoming;
}

/// One row of the Coaches Summary table.
/// [values] = Skills, Sessions, Training, Quizzes, Tracker, AI Sessions, each (all time, last 7 days).
class SummaryRow {
  const SummaryRow({required this.player, required this.values, required this.allocatedCompleted});
  final CoachPlayer player;
  final List<int> values;
  final bool allocatedCompleted;
}

/// Column of the Coaches Summary table that opens a history popup.
enum SummaryDetailType {
  skill('skill', 'SKILLS COMPLETED'),
  session('session', 'SESSIONS COMPLETED'),
  allocatedTraining('allocated_training', 'ALLOCATED TRAINING'),
  quiz('quiz', 'QUIZZES TAKEN'),
  tracker('tracker', 'TRACKER UPDATES'),
  aiSessions('ai_sessions', 'AI SESSIONS');

  const SummaryDetailType(this.apiValue, this.label);

  /// `type` query value of `coach-summary-detail`.
  final String apiValue;

  /// Popup heading ("QUIZZES TAKEN · ALL TIME").
  final String label;

  /// Same order as the table groups (and [SummaryRow.values] pairs).
  static const List<SummaryDetailType> columns = <SummaryDetailType>[
    skill,
    session,
    allocatedTraining,
    quiz,
    tracker,
    aiSessions,
  ];
}

/// One drill of an AI session.
class SummaryDrill {
  const SummaryDrill({required this.title, required this.completed});
  final String title;
  final bool completed;
}

/// One line of a summary popup (skill, session, quiz, match, AI session...).
class SummaryHistoryItem {
  const SummaryHistoryItem({required this.title, this.completedAt, this.drills = const <SummaryDrill>[]});
  final String title;
  final DateTime? completedAt;

  /// AI sessions only.
  final List<SummaryDrill> drills;
}

/// `coach-summary-detail` answer for one player + one column.
class SummaryDetail {
  const SummaryDetail({this.player, this.allTime = const <SummaryHistoryItem>[], this.lastSevenDays = const <SummaryHistoryItem>[]});
  final CoachPlayer? player;
  final List<SummaryHistoryItem> allTime;
  final List<SummaryHistoryItem> lastSevenDays;

  List<SummaryHistoryItem> items({required bool lastSevenDays}) => lastSevenDays ? this.lastSevenDays : allTime;
}

/// "27 Nov 2026, 13:22"
String formatSummaryTime(DateTime t) {
  const m = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.day)} ${m[t.month - 1]} ${t.year}, ${two(t.hour)}:${two(t.minute)}';
}
