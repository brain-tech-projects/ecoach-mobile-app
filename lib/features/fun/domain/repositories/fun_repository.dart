import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';

/// Source of Fun content (challenges + quizzes). `ApiFunRepository` talks to
/// the backend through `ApiService`.
abstract interface class FunRepository {
  // ---- Challenges -------------------------------------------------------
  Future<ApiResponse<List<Challenge>>> fetchChallenges();

  Future<ApiResponse<Challenge>> fetchChallenge(String challengeId);

  Future<ApiResponse<void>> setFavorite(String challengeId, bool favorite);

  Future<ApiResponse<List<ChallengeNote>>> fetchNotes(String challengeId);

  Future<ApiResponse<void>> addNote(String challengeId, String note);

  Future<ApiResponse<void>> updateNote(int noteId, String note);

  Future<ApiResponse<void>> deleteNote(int noteId);

  // ---- Quizzes ----------------------------------------------------------
  Future<ApiResponse<List<QuizGroup>>> fetchQuizGroups();

  Future<ApiResponse<List<QuizSummary>>> fetchQuizzes(String groupId);

  Future<ApiResponse<Quiz>> fetchQuiz(QuizSummary summary);

  /// [answers] holds the chosen option index per question (`null` = skipped).
  Future<ApiResponse<QuizResult>> submitQuiz(Quiz quiz, List<int?> answers);
}
