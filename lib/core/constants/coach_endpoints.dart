/// Coach-only endpoints (paths relative to `Env.baseUrl`).
/// Kept apart from [ApiEndpoints] so the player API list is never touched.
abstract final class CoachEndpoints {
  // Home
  static const String dashboardDetails = '/dashboard-details';

  static const String coachSummary = '/coach-summary';

  // Teams
  static const String storeTeam = '/store-team';
  static const String getTeam = '/get-team';
  static const String detailTeam = '/detail-team';
  static const String updateTeam = '/update-team';
  static const String deleteTeam = '/delete-team';
  static const String assignTeamPlayers = '/assign-team-players';
  static const String deleteGroup = '/delete-group';

  // Players
  static const String myTeam = '/my-team';
  static const String userDetail = '/user-detail';
  static const String coachNotification = '/coach-notification';

  // Programs (trainings)
  static const String getTraining = '/get-training';
  static const String detailTraining = '/detail-training';
  static const String storeTraining = '/store-training';
  static const String updateTraining = '/update-training';
  static const String deleteTraining = '/delete-training';
  static const String assignPlayers = '/assign-players';
  static const String programSkillTypes = '/program-skill-types';
  static const String programSkillVideos = '/program-skill-videos';

  // Own-video upload (S3 multipart)
  static const String videoUploadInitiate = '/video-upload/initiate';
  static const String videoUploadPartUrls = '/video-upload/part-urls';
  static const String videoUploadComplete = '/video-upload/complete';
}
