/// UI-only models (dummy data for now; replace with API models later).
class CoachHomeStats {
  const CoachHomeStats({this.teams = 0, this.trainings = 0, this.players = 0});
  final int teams;
  final int trainings;
  final int players;
}

class CoachPlayer {
  const CoachPlayer({required this.id, required this.name, this.subtitle = '', this.photoUrl, this.countryCode});
  final int id;
  final String name;
  final String subtitle;
  final String? photoUrl;
  final String? countryCode;
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
  const CoachTeam({required this.id, required this.name, this.description = '', this.imageUrl, this.groups = const <TeamGroup>[]});
  final int id;
  final String name;
  final String description;

  /// http(s) URL or a local file path.
  final String? imageUrl;
  final List<TeamGroup> groups;

  CoachTeam copyWith({String? name, String? description, String? imageUrl, List<TeamGroup>? groups}) => CoachTeam(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    groups: groups ?? this.groups,
  );
}

class TrainingProgram {
  const TrainingProgram({required this.id, required this.title, this.playerIds = const <int>[]});
  final int id;
  final String title;
  final List<int> playerIds;
  int get playerCount => playerIds.length;
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
  const PlayerInvitation({required this.id, required this.player});
  final int id;
  final CoachPlayer player;
}

/// One row of the Coaches Summary table.
/// [values] = Skills, Sessions, Training, Quizzes, Tracker, AI Sessions, each (all time, last 7 days).
class SummaryRow {
  const SummaryRow({required this.player, required this.values, required this.allocatedCompleted});
  final CoachPlayer player;
  final List<int> values;
  final bool allocatedCompleted;
}
