import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/features/auth/data/signup_content.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

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
    this.biggestDifference,
    this.frequency,
    this.dateOfBirth,
    this.photoAsset,
    this.photoUrl,
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
  final String? biggestDifference;
  final String? frequency;
  final DateTime? dateOfBirth;
  final String? photoAsset;
  final String? photoUrl;
}

/// Choices of the profile drop-downs (replace with API lists when needed).
abstract final class ProfileOptions {
  static final List<String> ages =
      List<String>.generate(45, (i) => '${i + 4}'); // 4 - 48
  // Same wording as the sign-up questions, because that is what the API
  // stores (e.g. "Just starting out", "2× a week").
  static List<String> _labels(SignUpStepKind kind) => SignUpContent
      .questionFor(kind)!
      .options
      .map((o) => o.label)
      .toList();

  static List<String> get positions => _labels(SignUpStepKind.positions);
  static List<String> get levels => _labels(SignUpStepKind.level);
  static List<String> get improve => _labels(SignUpStepKind.improve);
  static List<String> get biggestDifference =>
      _labels(SignUpStepKind.difference);
  static List<String> get frequency => _labels(SignUpStepKind.frequency);
  static const Map<String, String> countries = <String, String>{
    'AU': 'Australia', 'BR': 'Brazil', 'CA': 'Canada', 'EG': 'Egypt',
    'FR': 'France', 'DE': 'Germany', 'GH': 'Ghana', 'IN': 'India',
    'IE': 'Ireland', 'IT': 'Italy', 'KE': 'Kenya', 'MX': 'Mexico',
    'NL': 'Netherlands', 'NZ': 'New Zealand', 'NG': 'Nigeria',
    'PT': 'Portugal', 'SA': 'Saudi Arabia', 'ZA': 'South Africa',
    'ES': 'Spain', 'AE': 'United Arab Emirates', 'GB': 'United Kingdom',
    'US': 'United States', 'ZM': 'Zambia', 'ZW': 'Zimbabwe',
  };

  /// "ZW" -> 🇿🇼
  static String flag(String code) => code.length != 2
      ? ''
      : String.fromCharCodes(
          code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
        );
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
  const NoteNode({
    required this.id,
    required this.title,
    this.thumbnail,
    this.notes = const <NoteEntry>[],
    this.children = const <NoteNode>[],
  });

  final String id;
  final String title;
  final String? thumbnail;
  final List<NoteEntry> notes;
  final List<NoteNode> children;
}

enum MessageStatus { sent, seen }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.mine,
    this.status = MessageStatus.sent,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final bool mine;
  final MessageStatus status;
}

enum NotificationKind { skillVideo, quiz, other }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
}

/// Date helpers shared by Notes / Chat / Notifications.
abstract final class PlayerFormat {
  static const List<String> _mon = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
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
