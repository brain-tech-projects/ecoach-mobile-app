import 'package:flutter/foundation.dart';

/// A video challenge ("Maradona 7", "Wheelie Bins"...).
///
/// [thumbnail] is an `assets/...` path (dummy data) or an `https://...` URL
/// (API). TODO(api): add `Challenge.fromJson` (use `Env.mediaUrl` for the
/// relative image / video paths, like `TrainingVideo.fromJson`).
@immutable
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    this.isFavorite = false,
    this.note = '',
  });

  final String id;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final bool isFavorite;

  /// The user's own note for this challenge ("" = none).
  final String note;

  Challenge copyWith({bool? isFavorite, String? note}) => Challenge(
    id: id,
    title: title,
    thumbnail: thumbnail,
    videoUrl: videoUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    note: note ?? this.note,
  );
}

/// A group of quizzes ("Genius Kids and Adults Quiz", "Kids Football Quiz").
@immutable
class QuizGroup {
  const QuizGroup({required this.id, required this.name, required this.logo});

  final String id;
  final String name;

  /// `assets/...` path or `https://...` URL.
  final String logo;
}

/// One row of a group's list ("World Cup Quiz", "Quiz 1"...).
@immutable
class QuizSummary {
  const QuizSummary({
    required this.id,
    required this.title,
    required this.logo,
    this.questionCount = 0,
  });

  final String id;
  final String title;
  final String logo;
  final int questionCount;
}

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.correctIndex,
  });

  final String id;
  final String text;

  /// Answer texts in display order (shown as A, B, C, D...).
  final List<String> options;

  /// Index of the right answer. `null` when the backend only reveals it
  /// after submitting (then it comes back in [QuizResult.correctAnswers]).
  final int? correctIndex;
}

@immutable
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.questions,
    this.pointsPerQuestion = 5,
    this.imageUrl,
  });

  final String id;
  final String title;
  final List<QuizQuestion> questions;
  final int pointsPerQuestion;

  /// Optional picture above the title on the start screen.
  final String? imageUrl;

  int get maxScore => questions.length * pointsPerQuestion;
}

/// Outcome of a submitted quiz.
@immutable
class QuizResult {
  const QuizResult({
    required this.score,
    required this.maxScore,
    required this.correct,
    required this.total,
    required this.selected,
    required this.correctAnswers,
  });

  final int score;
  final int maxScore;
  final int correct;
  final int total;

  /// The user's answer per question (`null` = unanswered).
  final List<int?> selected;

  /// The right answer per question (`null` = unknown).
  final List<int?> correctAnswers;
}

/// Arguments of the "Review your answers" page.
@immutable
class QuizReviewArgs {
  const QuizReviewArgs({required this.quiz, required this.result});

  final Quiz quiz;
  final QuizResult result;
}
