import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';

class ApiFunRepository implements FunRepository {
  ApiFunRepository(this._api);

  final ApiService _api;

  static int _id(String id) => int.tryParse(id) ?? 0;

  // ---- Challenges -----------------------------------------------------------

  @override
  Future<ApiResponse<List<Challenge>>> fetchChallenges() =>
      _api.getChallenges();

  @override
  Future<ApiResponse<Challenge>> fetchChallenge(String challengeId) =>
      _api.getChallengeDetails(_id(challengeId));

  @override
  Future<ApiResponse<void>> setFavorite(String challengeId, bool favorite) =>
      _api.setChallengeFavourite(_id(challengeId), add: favorite);

  @override
  Future<ApiResponse<List<ChallengeNote>>> fetchNotes(String challengeId) =>
      _api.getChallengeNotes(_id(challengeId));

  @override
  Future<ApiResponse<void>> addNote(String challengeId, String note) =>
      _api.addChallengeNote(_id(challengeId), note);

  @override
  Future<ApiResponse<void>> updateNote(int noteId, String note) =>
      _api.updateChallengeNote(noteId, note);

  @override
  Future<ApiResponse<void>> deleteNote(int noteId) =>
      _api.deleteChallengeNote(noteId);

  // ---- Quizzes --------------------------------------------------------------

  @override
  Future<ApiResponse<List<QuizGroup>>> fetchQuizGroups() => _api.getQuizTypes();

  @override
  Future<ApiResponse<List<QuizSummary>>> fetchQuizzes(String groupId) =>
      _api.getQuizzes(_id(groupId));

  @override
  Future<ApiResponse<Quiz>> fetchQuiz(QuizSummary summary) async {
    final res = await _api.getQuizQuestions(_id(summary.id));
    return res.map<Quiz>((list) {
      if (list == null) return null;
      // The API lists newest first; play them in creation order.
      final questions = [...list]
        ..sort((a, b) => _id(a.id).compareTo(_id(b.id)));
      return Quiz(
        id: summary.id,
        title: summary.title,
        questions: questions,
        pointsPerQuestion: summary.marksPerQuestion,
      );
    });
  }

  @override
  Future<ApiResponse<QuizResult>> submitQuiz(
    Quiz quiz,
    List<int?> answers,
  ) async {
    final payload = <Map<String, String>>[];
    for (var i = 0; i < quiz.questions.length; i++) {
      final a = i < answers.length ? answers[i] : null;
      final q = quiz.questions[i];
      if (a == null || a < 0 || a >= q.options.length) continue;
      payload.add(<String, String>{
        'question_id': q.id,
        'selected_answer': q.options[a],
      });
    }

    final res = await _api.submitQuiz(quiz.id, payload);
    return res.map<QuizResult>((data) {
      if (data == null) return null;

      // The server only says which of the user's answers were right.
      final right = <String, bool>{};
      final details = data['details'];
      if (details is List) {
        for (final d in details.whereType<Map>()) {
          right['${d['question_id']}'] = d['is_correct'] == true;
        }
      }
      int n(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

      return QuizResult(
        score: n(data['score']),
        maxScore: n(data['max_score']),
        correct: n(data['total_correct_answers']),
        total: n(data['total_questions']),
        selected: List<int?>.from(answers),
        correctAnswers: <int?>[
          for (var i = 0; i < quiz.questions.length; i++)
            (i < answers.length && right[quiz.questions[i].id] == true)
                ? answers[i]
                : null,
        ],
      );
    });
  }
}
