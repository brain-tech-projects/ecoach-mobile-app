import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';

/// Source of Fun content (challenges + quizzes). `DummyFunRepository` is used
/// until the backend is ready: write an `ApiFunRepository` (methods in
/// `ApiService` + paths in `ApiEndpoints`, like Training) and swap it in
/// `fun_binding.dart`. Controllers and pages stay untouched.
abstract interface class FunRepository {
  // ---- Challenges -------------------------------------------------------
  Future<ApiResponse<List<Challenge>>> fetchChallenges();

  Future<ApiResponse<void>> setFavorite(String challengeId, bool favorite);

  Future<ApiResponse<void>> saveNote(String challengeId, String note);

  // ---- Quizzes ----------------------------------------------------------
  Future<ApiResponse<List<QuizGroup>>> fetchQuizGroups();

  Future<ApiResponse<List<QuizSummary>>> fetchQuizzes(String groupId);

  Future<ApiResponse<Quiz>> fetchQuiz(String quizId);

  /// [answers] holds the chosen option index per question (`null` = skipped).
  Future<ApiResponse<QuizResult>> submitQuiz(
    String quizId,
    List<int?> answers,
  );
}
