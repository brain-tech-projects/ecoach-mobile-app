import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';

/// Everything behind the profile-menu pages. Every method may throw; the
/// controllers show a toast / retry. Swap the dummy for an API version in
/// `ensurePlayerRepository()` (player_binding.dart).
abstract interface class PlayerRepository {
  // My Profile
  Future<PlayerProfile> fetchProfile();
  Future<void> updateProfile(PlayerProfile profile);

  // My Skills ("All Skills"; challenges come from `FunRepository` favourites)
  Future<List<SavedSkill>> fetchSavedSkills();
  Future<void> removeSavedSkill(int drillId);

  // Notes
  /// Skill notes grouped by skill area > drill. (Challenge notes come from
  /// `FunRepository`.)
  Future<List<NoteNode>> fetchSkillNotes();
  Future<void> deleteNote(String noteId);

  /// Challenge notes grouped by challenge (ids prefixed `challenge:`).
  Future<List<NoteNode>> fetchChallengeNotes();

  // Chat with the coach
  Future<List<ChatMessage>> fetchMessages(String coachId);
  Future<ChatMessage> sendMessage(String coachId, String text);

  // Notifications
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markAllNotificationsRead();
}
