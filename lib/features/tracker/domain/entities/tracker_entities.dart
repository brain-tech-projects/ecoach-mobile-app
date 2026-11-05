import 'package:flutter/foundation.dart';

/// One rated match ("Rating Tracker" entry).
@immutable
class MatchEntry {
  const MatchEntry({
    required this.id,
    required this.opponent,
    required this.playedOn,
    required this.score,
    required this.passing,
    required this.dribbling,
    required this.shooting,
    required this.defending,
    required this.pace,
    required this.physicality,
    required this.assists,
    required this.goals,
    required this.saves,
    this.photoUrl,
    this.photoPath,
  });

  /// Empty id = not saved yet.
  final String id;
  final String opponent;
  final DateTime playedOn;
  final String score;
  final int passing;
  final int dribbling;
  final int shooting;
  final int defending;
  final int pace;
  final int physicality;
  final int assists;
  final int goals;
  final int saves;

  /// Photo already stored on the server.
  final String? photoUrl;

  /// Photo picked on this device, not uploaded yet.
  final String? photoPath;

  MatchEntry copyWith({String? id, String? photoUrl, String? photoPath}) => MatchEntry(
        id: id ?? this.id,
        opponent: opponent,
        playedOn: playedOn,
        score: score,
        passing: passing,
        dribbling: dribbling,
        shooting: shooting,
        defending: defending,
        pace: pace,
        physicality: physicality,
        assists: assists,
        goals: goals,
        saves: saves,
        photoUrl: photoUrl ?? this.photoUrl,
        photoPath: photoPath ?? this.photoPath,
      );

  /// "JANUARY 27, 2026"
  String get longDate => TrackerFormat.longDate(playedOn);

  /// "01/27/26"
  String get shortDate => TrackerFormat.shortDate(playedOn);
}

/// Everything the Rating Tracker page shows.
@immutable
class TrackerData {
  const TrackerData({
    required this.playerName,
    required this.entries,
    this.photoAsset,
    this.photoUrl,
  });

  final String playerName;
  final String? photoAsset;
  final String? photoUrl;
  final List<MatchEntry> entries;

  int get goals => entries.fold(0, (a, e) => a + e.goals);
  int get assists => entries.fold(0, (a, e) => a + e.assists);
  int get saves => entries.fold(0, (a, e) => a + e.saves);

  int _avg(int Function(MatchEntry) pick) => entries.isEmpty
      ? 0
      : (entries.fold<int>(0, (a, e) => a + pick(e)) / entries.length).round();

  int get passing => _avg((e) => e.passing);
  int get dribbling => _avg((e) => e.dribbling);
  int get shooting => _avg((e) => e.shooting);
  int get defending => _avg((e) => e.defending);
  int get pace => _avg((e) => e.pace);
  int get physicality => _avg((e) => e.physicality);

  /// Years that have matches, newest first.
  List<int> get years =>
      (entries.map((e) => e.playedOn.year).toSet().toList()..sort((a, b) => b.compareTo(a)));
}

abstract final class TrackerFormat {
  static const List<String> _months = <String>[
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY',
    'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];
  static String _two(int v) => v.toString().padLeft(2, '0');

  static String longDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
  static String shortDate(DateTime d) => '${_two(d.month)}/${_two(d.day)}/${_two(d.year % 100)}';

  /// Form field: dd/mm/yyyy
  static String formDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
}

enum StepKind { text, date, number, photo }

/// One screen of the 13-step "Match Rating" form.
@immutable
class MatchStep {
  const MatchStep({
    required this.key,
    required this.kind,
    required this.question,
    this.hint,
    this.placeholder = '',
    this.image,
    this.imageAspect = 969 / 645,
    this.min = 0,
    this.max = 100,
    this.multiline = false,
  });

  final String key;
  final StepKind kind;
  final String question;

  /// Small line under the question, e.g. "(Rate 1– 100)".
  final String? hint;
  final String placeholder;
  final String? image;
  final double imageAspect;
  final int min;
  final int max;
  final bool multiline;
}

abstract final class MatchSteps {
  static const String _dir = 'assets/images/tracker';
  static const String _rate = '(Rate 1– 100)';

  static const List<MatchStep> all = <MatchStep>[
    MatchStep(
      key: 'opponent', kind: StepKind.text, multiline: true,
      question: 'Which team did you play against?',
      placeholder: 'Enter team name', image: '$_dir/step_01.jpg',
    ),
    MatchStep(
      key: 'date', kind: StepKind.date,
      question: 'When did you play this match?',
      placeholder: 'dd/mm/yyyy', image: '$_dir/step_02.jpg',
    ),
    MatchStep(
      key: 'score', kind: StepKind.text, multiline: true,
      question: 'What was the score in the game? W/L',
      placeholder: 'For example; W 2-1 or  L 2-1',
      image: '$_dir/step_03.jpg', imageAspect: 969 / 774,
    ),
    MatchStep(
      key: 'passing', kind: StepKind.number, min: 1,
      question: 'Rate your passing', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_04.jpg',
    ),
    MatchStep(
      key: 'dribbling', kind: StepKind.number, min: 1,
      question: 'Rate your dribbling', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_05.jpg',
    ),
    MatchStep(
      key: 'shooting', kind: StepKind.number, min: 1,
      question: 'Rate your shooting', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_06.jpg',
    ),
    MatchStep(
      key: 'defending', kind: StepKind.number, min: 1,
      question: 'How would you rate your defending?', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_07.jpg',
    ),
    MatchStep(
      key: 'pace', kind: StepKind.number, min: 1,
      question: 'Rate your pace', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_08.jpg',
    ),
    MatchStep(
      key: 'physicality', kind: StepKind.number, min: 1,
      question: 'Rate your physicality', hint: _rate,
      placeholder: 'Type a number…', image: '$_dir/step_09.jpg',
    ),
    MatchStep(
      key: 'assists', kind: StepKind.number,
      question: 'How many assists did you make?',
      placeholder: '0-100', image: '$_dir/step_10.jpg',
    ),
    MatchStep(
      key: 'goals', kind: StepKind.number,
      question: 'How many goals did you score?',
      placeholder: 'Number of goals (0-100)', image: '$_dir/step_11.jpg',
    ),
    MatchStep(
      key: 'saves', kind: StepKind.number,
      question: 'How many saves did you make?',
      placeholder: 'Type a number…', image: '$_dir/step_12.jpg',
    ),
    MatchStep(
      key: 'photo', kind: StepKind.photo,
      question: 'Upload a picture from the game',
    ),
  ];
}
