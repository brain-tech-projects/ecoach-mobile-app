import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Which screen a notification opens when tapped.
///
/// The API's `redirect_type` is checked first; when it is empty or unknown the
/// notification's title / text is used. Returns null when there is nowhere
/// sensible to go (the tap then does nothing).
abstract final class NotificationRoute {
  static String? of(AppNotification n) =>
      _classify(n.redirectType) ?? _classify('${n.title} ${n.body}');

  /// Arguments the target route needs.
  static Object? argumentsFor(String route) =>
      route == AppRoutes.skillList ? SkillCategory.all : null;

  static String? _classify(String raw) {
    final t = raw.toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (t.isEmpty) return null;
    bool has(List<String> words) => words.any(t.contains);

    if (has(<String>['quiz'])) return AppRoutes.quizzes;
    if (has(<String>['challenge'])) return AppRoutes.challenges;
    if (has(<String>['chat', 'message'])) return AppRoutes.chats;
    if (has(<String>['invitation', 'invite', 'connect request', 'coach request'])) {
      return AppRoutes.coachInvitation;
    }
    if (has(<String>['trophy', 'reward', 'points'])) return AppRoutes.trophyRoom;
    if (has(<String>['personal'])) return AppRoutes.personalTraining;
    // Opens "All Skills" (same screen as Personal Training > Add Skills > All Skills).
    if (has(<String>['skill'])) return AppRoutes.skillList;
    if (has(<String>['train', 'session', 'program'])) {
      // Videos the coach assigned live in "Coaches Training"; the rest of the
      // training videos are in "My Training".
      return has(<String>['coach', 'allocat', 'assign'])
          ? AppRoutes.coachTraining
          : AppRoutes.training;
    }
    if (has(<String>['tracker', 'match', 'rating'])) return AppRoutes.ratingTracker;
    if (has(<String>['subscription', 'plan', 'premium'])) return AppRoutes.subscription;
    return null;
  }
}
