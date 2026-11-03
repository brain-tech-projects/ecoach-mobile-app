/// Paths are relative to [Env.baseUrl].
abstract final class ApiEndpoints {
  // Auth
  static const String register = '/register';
  static const String resendOtp = '/resend-otp';
  static const String verifyOtp = '/verify-otp';
  static const String login = '/login';

  // Password reset
  static const String forgotPassword = '/forgot-password';
  static const String verifyResetOtp = '/verify-reset-otp';
  static const String resetPassword = '/reset-password';

  // Home
  static const String banners = '/banners';
  static const String details = '/details';
  static const String unreadCount = '/unread-count';

  // Training
  static const String trainingTypes = '/training-types';
  static const String trainingVideos = '/training-videos';

  // Skills
  static const String skillTypes = '/skill-types';
  static const String skillVideos = '/skill-videos';
  static const String skillVideoDetails = '/skill-video-details';
  static const String markSkillVideoCompleted = '/mark-skill-video-completed';
  static const String addVideoToPersonalized = '/add-video-to-personalized';
  static const String addSkillToPersonalized = '/add-skill-to-personalized';
  static const String storeSkillNote = '/store-skill-note';
  static const String getSkillNotes = '/get-skill-notes';
  static const String updateSkillNote = '/update-skill-note';
  static const String deleteSkillNote = '/delete-skill-note';
}
