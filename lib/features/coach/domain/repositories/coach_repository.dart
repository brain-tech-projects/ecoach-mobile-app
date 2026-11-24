import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';

abstract interface class CoachRepository {
  /// The connected coach, or null when not connected.
  Future<Coach?> fetchConnectedCoach();

  /// Ends the connection. Throws on failure.
  Future<void> disconnect(String coachId);

  /// Skills set by the coach.
  Future<List<AssignedTraining>> fetchAssignedTrainings();

  /// Marks an assigned training as completed. Throws on failure.
  Future<void> completeTraining(String trainingId);

  /// Pending invitations coaches sent to this player.
  Future<List<CoachInvite>> fetchPendingInvitations();

  /// Accept / reject a coach's invitation; returns the server's message.
  Future<String> respondInvitation(int invitationId, {required bool accept});

  /// Emails an invitation to a coach; returns the server's message.
  Future<String> inviteCoach(String email);
}
