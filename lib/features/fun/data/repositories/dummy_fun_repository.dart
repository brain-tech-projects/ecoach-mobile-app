import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/fun/data/fun_assets.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';

/// In-memory dummy data. State is static so favourites / notes survive
/// leaving and re-entering a page during the session.
class DummyFunRepository implements FunRepository {
  static const String _video =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const int _points = 5;

  static final Set<String> _favorites = {'wheelie-bins'};
  static final Map<String, String> _notes = {};

  static const List<(String, String, String)> _challengeSeed = [
    ('maradona-7', 'Maradona 7', FunAssets.challengeMaradona),
    ('wheelie-bins', 'Wheelie Bins', FunAssets.challengeWheelie),
    ('bottled-it', 'Bottled It!', FunAssets.challengeBottled),
    ('bottled-it-2', 'Bottled It - Part 2!', FunAssets.challengeBottled2),
  ];

  static const List<QuizGroup> _groups = [
    QuizGroup(
      id: 'genius',
      name: 'Genius Kids and Adults Quiz',
      logo: FunAssets.quizGenius,
    ),
    QuizGroup(
      id: 'kids',
      name: 'Kids Football Quiz',
      logo: FunAssets.quizKids,
    ),
  ];

  // quizId -> (title, logo, groupId, question set)
  static final Map<String, (String, String, String, List<QuizQuestion>)>
  _quizzes = {
    'world-cup': ('World Cup Quiz', FunAssets.quizWorldCup, 'genius', _worldCup),
    'genius-1': ('Quiz 1', FunAssets.quiz1, 'genius', _general),
    'genius-2': ('Quiz 2', FunAssets.quiz2, 'genius', _rules),
    'genius-3': ('Quiz 3', FunAssets.quiz3, 'genius', _general),
    'genius-4': ('Quiz 4', FunAssets.quiz4, 'genius', _rules),
    'kids-1': ('Quiz 1', FunAssets.quiz1, 'kids', _general),
    'kids-2': ('Quiz 2', FunAssets.quiz2, 'kids', _rules),
    'kids-3': ('Quiz 3', FunAssets.quiz3, 'kids', _general),
  };

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 200));

  ApiResponse<T> _ok<T>(T data) =>
      ApiResponse<T>(success: true, message: '', data: data);

  ApiResponse<T> _fail<T>(String message) =>
      ApiResponse<T>(success: false, message: message);

  @override
  Future<ApiResponse<List<Challenge>>> fetchChallenges() async {
    await _latency();
    return _ok([
      for (final c in _challengeSeed)
        Challenge(
          id: c.$1,
          title: c.$2,
          thumbnail: c.$3,
          videoUrl: _video,
          isFavorite: _favorites.contains(c.$1),
          note: _notes[c.$1] ?? '',
        ),
    ]);
  }

  @override
  Future<ApiResponse<void>> setFavorite(String id, bool favorite) async {
    await _latency();
    favorite ? _favorites.add(id) : _favorites.remove(id);
    return _ok<void>(null);
  }

  @override
  Future<ApiResponse<void>> saveNote(String id, String note) async {
    await _latency();
    note.isEmpty ? _notes.remove(id) : _notes[id] = note;
    return _ok<void>(null);
  }

  @override
  Future<ApiResponse<List<QuizGroup>>> fetchQuizGroups() async {
    await _latency();
    return _ok(_groups);
  }

  @override
  Future<ApiResponse<List<QuizSummary>>> fetchQuizzes(String groupId) async {
    await _latency();
    return _ok([
      for (final e in _quizzes.entries)
        if (e.value.$3 == groupId)
          QuizSummary(
            id: e.key,
            title: e.value.$1,
            logo: e.value.$2,
            questionCount: e.value.$4.length,
          ),
    ]);
  }

  @override
  Future<ApiResponse<Quiz>> fetchQuiz(String quizId) async {
    await _latency();
    final q = _quizzes[quizId];
    if (q == null) return _fail('Quiz not found.');
    return _ok(
      Quiz(
        id: quizId,
        title: q.$1,
        questions: q.$4,
        pointsPerQuestion: _points,
      ),
    );
  }

  @override
  Future<ApiResponse<QuizResult>> submitQuiz(
    String quizId,
    List<int?> answers,
  ) async {
    await _latency();
    final q = _quizzes[quizId];
    if (q == null) return _fail('Quiz not found.');
    final questions = q.$4;
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (i < answers.length && answers[i] == questions[i].correctIndex) {
        correct++;
      }
    }
    return _ok(
      QuizResult(
        score: correct * _points,
        maxScore: questions.length * _points,
        correct: correct,
        total: questions.length,
        selected: List<int?>.from(answers),
        correctAnswers: [for (final x in questions) x.correctIndex],
      ),
    );
  }
}

QuizQuestion _q(String id, String text, List<String> o, int correct) =>
    QuizQuestion(id: id, text: text, options: o, correctIndex: correct);

final List<QuizQuestion> _worldCup = [
  _q('w1', 'How many goals did Kylian Mbappe score in the 2022 world cup final?', ['0', '1', '2', '3'], 3),
  _q('w2', 'Which country won the first FIFA World Cup in 1930?', ['Brazil', 'Uruguay', 'Argentina', 'Italy'], 1),
  _q('w3', 'Which country won the 2018 FIFA World Cup?', ['Croatia', 'Germany', 'France', 'Belgium'], 2),
  _q('w4', 'Who is the all-time top scorer in World Cup history?', ['Pele', 'Miroslav Klose', 'Ronaldo', 'Lionel Messi'], 1),
  _q('w5', 'Who won the Golden Ball at the 2022 World Cup?', ['Kylian Mbappe', 'Luka Modric', 'Lionel Messi', 'Antoine Griezmann'], 2),
  _q('w6', 'Which nation has won the most World Cup titles?', ['Germany', 'Brazil', 'Italy', 'Argentina'], 1),
  _q('w7', 'Which country hosted the 2014 FIFA World Cup?', ['Brazil', 'Germany', 'Russia', 'South Africa'], 0),
  _q('w8', 'Which African country hosted the 2010 World Cup?', ['Morocco', 'South Africa', 'Nigeria', 'Egypt'], 1),
  _q('w9', 'Who scored the famous "Hand of God" goal in 1986?', ['Pele', 'Diego Maradona', 'Zinedine Zidane', 'Johan Cruyff'], 1),
  _q('w10', 'How many teams played at the 2022 World Cup in Qatar?', ['24', '28', '32', '48'], 2),
];

final List<QuizQuestion> _general = [
  _q('g1', 'How many players does one team have on the pitch in a standard match?', ['9', '10', '11', '12'], 2),
  _q('g2', 'How long is a standard football match without extra time?', ['60 minutes', '80 minutes', '90 minutes', '100 minutes'], 2),
  _q('g3', 'Which card means a player is sent off?', ['Yellow', 'Red', 'Green', 'Blue'], 1),
  _q('g4', 'Which part of the body can outfield players NOT use to play the ball?', ['Head', 'Chest', 'Hands', 'Knee'], 2),
  _q('g5', 'What is it called when a player scores three goals in one match?', ['Brace', 'Hat-trick', 'Double', 'Combo'], 1),
  _q('g6', 'Which club is known as "The Gunners"?', ['Chelsea', 'Arsenal', 'Tottenham', 'Liverpool'], 1),
  _q('g7', 'In which country were the first modern football rules written?', ['England', 'Spain', 'Brazil', 'Italy'], 0),
  _q('g8', 'Which player is known as "CR7"?', ['Cristiano Ronaldo', 'Carlos Ruiz', 'Cesc Fabregas', 'Christian Romero'], 0),
  _q('g9', 'Which country won the 2022 FIFA World Cup?', ['France', 'Argentina', 'Croatia', 'Morocco'], 1),
  _q('g10', 'Where can a goalkeeper handle the ball?', ['Centre circle', 'Penalty area', 'Corner arc', 'Technical area'], 1),
];

final List<QuizQuestion> _rules = [
  _q('r1', 'The attackers last touch the ball before it crosses the goal line. What is awarded?', ['Corner', 'Goal kick', 'Throw-in', 'Free kick'], 1),
  _q('r2', 'How far is the penalty spot from the goal line?', ['8 yards', '10 yards', '12 yards', '14 yards'], 2),
  _q('r3', 'What does VAR stand for?', ['Video Assistant Referee', 'Visual Action Replay', 'Video Action Review', 'Verified Assistant Referee'], 0),
  _q('r4', 'Who may handle the ball inside their own penalty area?', ['Defender', 'Goalkeeper', 'Captain', 'Striker'], 1),
  _q('r5', 'What happens after a team scores a goal?', ['Kick-off by the other team', 'Goal kick', 'Throw-in', 'Penalty'], 0),
  _q('r6', 'Which card is a warning for unsporting behaviour?', ['Red card', 'Yellow card', 'Blue card', 'White card'], 1),
  _q('r7', 'How many yellow cards in one match lead to a sending off?', ['1', '2', '3', '4'], 1),
  _q('r8', 'From where is a throw-in taken?', ['Goal line', 'Touchline', 'Centre circle', 'Penalty spot'], 1),
  _q('r9', 'What is the minimum number of players a team needs to continue a match?', ['5', '6', '7', '8'], 2),
  _q('r10', 'How many assistant referees are there in a standard match?', ['1', '2', '3', '4'], 1),
];
