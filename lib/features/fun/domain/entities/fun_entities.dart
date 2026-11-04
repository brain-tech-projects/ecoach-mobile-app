import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/core/config/env.dart';

int _int(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

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

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: '${json['id']}',
    title: (json['name'] ?? '').toString(),
    thumbnail: Env.skillMediaUrl(json['image'] as String?) ?? '',
    // Video file names contain spaces ("Just for fun/Maradona 7 Final.mp4").
    videoUrl: (Env.skillMediaUrl(json['video'] as String?) ?? '').replaceAll(
      ' ',
      '%20',
    ),
    // `addToFavourite: true` means the "add" option is offered, i.e. the
    // challenge is NOT a favourite yet.
    isFavorite: json['addToFavourite'] == false,
  );

  final String id;
  final String title;
  final String thumbnail;
  final String videoUrl;
  final bool isFavorite;

  /// Unused with the API (notes are a list, see [ChallengeNote]).
  final String note;

  Challenge copyWith({
    bool? isFavorite,
    String? note,
    String? title,
    String? thumbnail,
    String? videoUrl,
  }) => Challenge(
    id: id,
    title: title ?? this.title,
    thumbnail: thumbnail ?? this.thumbnail,
    videoUrl: videoUrl ?? this.videoUrl,
    isFavorite: isFavorite ?? this.isFavorite,
    note: note ?? this.note,
  );
}

/// A group of quizzes ("Genius Kids and Adults Quiz", "Kids Football Quiz").
@immutable
class QuizGroup {
  const QuizGroup({required this.id, required this.name, required this.logo});

  factory QuizGroup.fromJson(Map<String, dynamic> json) => QuizGroup(
    id: '${json['id']}',
    name: (json['name'] ?? '').toString(),
    logo: Env.skillMediaUrl(json['icon'] as String?) ?? '',
  );

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
    this.marksPerQuestion = 5,
  });

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    final marks = _int(json['marks_per_question']);
    final max = _int(json['max_score']);
    return QuizSummary(
      id: '${json['id']}',
      title: (json['title'] ?? '').toString(),
      logo: Env.skillMediaUrl(json['icon'] as String?) ?? '',
      marksPerQuestion: marks > 0 ? marks : 5,
      // The API has no question count: max score / marks per question.
      questionCount: marks > 0 ? max ~/ marks : 0,
    );
  }

  final String id;
  final String title;
  final String logo;
  final int questionCount;
  final int marksPerQuestion;
}

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: '${json['id']}',
    text: (json['question'] ?? '').toString(),
    options: json['options'] is List
        ? (json['options'] as List).map((e) => e.toString()).toList()
        : const <String>[],
  );

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

/// A note on a challenge (`/get-challenge-notes`).
@immutable
class ChallengeNote {
  const ChallengeNote({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory ChallengeNote.fromJson(Map<String, dynamic> json) => ChallengeNote(
    id: _int(json['id']),
    text: (json['note'] ?? '').toString(),
    createdAt:
        DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal() ??
        DateTime.now(),
  );

  final int id;
  final String text;
  final DateTime createdAt;
}
