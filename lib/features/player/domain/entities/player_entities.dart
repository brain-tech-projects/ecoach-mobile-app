import 'package:ecoach_pro/features/auth/data/countries_data.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';
import 'package:ecoach_pro/features/auth/data/signup_content.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';

/// Editable "My Profile" data.
@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.profileName,
    required this.fullName,
    required this.parentEmail,
    required this.countryCode,
    required this.club,
    required this.favouritePosition,
    required this.favouriteTeam,
    this.age,
    this.positions = const <String>[],
    this.levels = const <String>[],
    this.improve = const <String>[],
    this.biggestDifference = const <String>[],
    this.frequency,
    this.dateOfBirth,
    this.photoAsset,
    this.photoUrl,
    this.photoPath,
  });

  final String profileName;
  final String fullName;
  final String parentEmail;
  final String countryCode; // ISO-3166 alpha-2, e.g. "ZW"
  final String club;
  final String favouritePosition;
  final String favouriteTeam;
  final int? age;
  final List<String> positions;
  final List<String> levels;
  final List<String> improve;
  final List<String> biggestDifference;
  final String? frequency;
  final DateTime? dateOfBirth;
  final String? photoAsset;
  final String? photoUrl;

  /// Newly picked local photo, uploaded on save (null = keep the current one).
  final String? photoPath;
}

/// Choices of the profile drop-downs (replace with API lists when needed).
abstract final class ProfileOptions {
  static final List<String> ages = List<String>.generate(45, (i) => '${i + 4}'); // 4 - 48
  // Same wording as the sign-up questions, because that is what the API
  // stores (e.g. "Just starting out", "2× a week").
  static List<String> _labels(SignUpStepKind kind) => SignUpContent.questionFor(kind)!.options.map((o) => o.label).toList();

  static List<String> get positions => _labels(SignUpStepKind.positions);
  static List<String> get levels => _labels(SignUpStepKind.level);
  static List<String> get improve => _labels(SignUpStepKind.improve);
  static List<String> get biggestDifference => _labels(SignUpStepKind.difference);
  static List<String> get frequency => _labels(SignUpStepKind.frequency);

  /// Every country (ISO alpha-2 code -> name), same source as the sign-up
  /// country picker so all screens show the full list.
  static final Map<String, String> countries = <String, String>{for (final c in Countries.all) c.code: c.name};

  /// "ZW" -> 🇿🇼
  static String flag(String code) => Country.flagOf(code);
}

/// A drill saved to My Skills.
@immutable
class SavedSkill {
  const SavedSkill({required this.drill});
  final Drill drill;
  String get id => '${drill.id}';
}

@immutable
class NoteEntry {
  const NoteEntry({required this.id, required this.text, this.date});
  final String id;
  final String text;

  /// null = the source has no date (challenge notes).
  final DateTime? date;
}

/// Notes tree: skill area > drill > notes, or challenge > notes.
@immutable
class NoteNode {
  const NoteNode({required this.id, required this.title, this.thumbnail, this.notes = const <NoteEntry>[], this.children = const <NoteNode>[]});

  final String id;
  final String title;
  final String? thumbnail;
  final List<NoteEntry> notes;
  final List<NoteNode> children;
}

/// `sending` / `failed` only exist on this phone (before the server confirms).
enum MessageStatus { sending, failed, sent, seen }

@immutable
class ChatMessage {
  const ChatMessage({required this.id, required this.text, required this.sentAt, required this.mine, this.status = MessageStatus.sent});

  final String id;
  final String text;
  final DateTime sentAt;
  final bool mine;
  final MessageStatus status;

  /// Created on this phone, not confirmed by the server yet.
  bool get isLocal => id.startsWith('local-');

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
    id: id,
    text: text,
    sentAt: sentAt,
    mine: mine,
    status: status ?? this.status,
  );
}

/// What a notification is about. Decides the icon and the screen it opens.
enum NotificationKind {
  trainingVideo,
  personalTraining,
  skillVideo,
  quiz,
  challenge,
  coachTraining,
  coachInvitation,
  chat,
  trophy,
  tracker,
  subscription,
  other;

  /// Reads the API `redirect_type` first; when it is empty or unknown the
  /// title / description wording is used ("New skills video added" ...).
  static NotificationKind resolve({String? redirectType, String title = '', String body = ''}) {
    final byType = _match((redirectType ?? '').toLowerCase());
    if (byType != NotificationKind.other) return byType;
    return _match('${title.toLowerCase()} ${body.toLowerCase()}');
  }

  static NotificationKind _match(String t) {
    if (t.trim().isEmpty) return NotificationKind.other;
    bool has(List<String> words) => words.any(t.contains);

    if (has(<String>['coach'])) {
      if (has(<String>['invit', 'connect', 'request'])) return NotificationKind.coachInvitation;
      return NotificationKind.coachTraining;
    }
    if (has(<String>['quiz'])) return NotificationKind.quiz;
    if (has(<String>['challenge'])) return NotificationKind.challenge;
    if (has(<String>['chat', 'message'])) return NotificationKind.chat;
    if (has(<String>['trophy', 'trophies', 'point', 'reward'])) return NotificationKind.trophy;
    if (has(<String>['rating', 'match', 'tracker'])) return NotificationKind.tracker;
    if (has(<String>['subscription', 'plan', 'premium'])) return NotificationKind.subscription;
    if (has(<String>['personal'])) return NotificationKind.personalTraining;
    if (has(<String>['skill'])) return NotificationKind.skillVideo;
    if (has(<String>['training', 'video', 'level'])) return NotificationKind.trainingVideo;
    return NotificationKind.other;
  }

  /// Named route opened when the row is tapped (null = nothing to open).
  String? get route {
    switch (this) {
      case NotificationKind.trainingVideo:
        return AppRoutes.training; // My Training
      case NotificationKind.personalTraining:
        return AppRoutes.personalTraining;
      case NotificationKind.skillVideo:
        return AppRoutes.mySkills; // My Skills
      case NotificationKind.quiz:
        return AppRoutes.quizzes;
      case NotificationKind.challenge:
        return AppRoutes.challenges;
      case NotificationKind.coachTraining:
        return AppRoutes.coachTraining;
      case NotificationKind.coachInvitation:
        return AppRoutes.coachInvitation;
      case NotificationKind.chat:
        return AppRoutes.chats;
      case NotificationKind.trophy:
        return AppRoutes.trophyRoom;
      case NotificationKind.tracker:
        return AppRoutes.ratingTracker;
      case NotificationKind.subscription:
        return AppRoutes.subscription;
      case NotificationKind.other:
        return null;
    }
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.redirectType = '',
    this.redirectId,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Raw API values, kept for deep links that need the id.
  final String redirectType;
  final String? redirectId;
}

/// Date helpers shared by Notes / Chat / Notifications.
abstract final class PlayerFormat {
  static const List<String> _mon = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String _two(int v) => v.toString().padLeft(2, '0');

  /// "03 Nov 2026"
  static String noteDate(DateTime d) => '${_two(d.day)} ${_mon[d.month - 1]} ${d.year}';

  /// "03:35 pm"
  static String clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '${_two(h)}:${_two(d.minute)} ${d.hour < 12 ? 'am' : 'pm'}';
  }

  /// "Today 03:35 pm" / "Yesterday 03:35 pm" / "16 Dec 2025 03:35 pm"
  static String chatTime(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = today.difference(day).inDays;
    final label = diff == 0
        ? 'Today'
        : diff == 1
        ? 'Yesterday'
        : noteDate(d);
    return '$label ${clock(d)}';
  }

  /// "3h ago"
  static String ago(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// "06/11/2025"
  static String dob(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
}
