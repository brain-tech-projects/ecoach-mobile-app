/// Models of the AI training session screens (built from `/ai/*`).
class AiProfile {
  const AiProfile({required this.age, required this.positions, required this.levels, required this.focus});
  final String age;
  final List<String> positions;
  final List<String> levels;
  final List<String> focus;
}

class AiChip {
  const AiChip(this.label, this.emoji, this.prompt);
  final String label;
  final String emoji;
  final String prompt;
}

class AiDrill {
  const AiDrill({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.note,
    required this.thumb,
    required this.videoUrl,
    this.mins = 5,
    this.points = 5,
    this.type = 'skill_video',
    this.completed = false,
    this.locked = false,
  });
  final int id;
  final String title;
  final String category;
  final String description;

  /// "Matches your request ..." line.
  final String note;
  final String thumb;
  final String videoUrl;
  final int mins;
  final int points;

  /// `drill_type` the API wants back on complete-drill.
  final String type;
  final bool completed;
  final bool locked;
}

class AiSession {
  const AiSession({required this.id, required this.request, required this.summary, required this.tags, required this.drills, this.completed = false});
  final int id;
  final String request;

  /// Typed word by word on the result screen.
  final String summary;
  final List<String> tags;
  final List<AiDrill> drills;

  /// Finished earlier (re-opened from "Recent sessions").
  final bool completed;

  int get totalMins => drills.fold(0, (a, d) => a + d.mins);
  int get totalPoints => drills.fold(0, (a, d) => a + d.points);
}

class AiSessionSummary {
  const AiSessionSummary({required this.id, required this.request, required this.when, this.drills = 4, this.mins = 20});
  final int id;
  final String request;
  final String when;
  final int drills;
  final int mins;
}
