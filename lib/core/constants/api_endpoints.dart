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

  // Fun: challenges
  static const String challenges = '/challenges';
  static const String challengeDetails = '/challenge-details';
  static const String toggleFavouriteChallenge = '/toggle-favourite-challenge';
  static const String storeChallengeNote = '/store-challenge-note';
  static const String getChallengeNotes = '/get-challenge-notes';
  static const String updateChallengeNote = '/update-challenge-note';
  static const String deleteChallengeNote = '/delete-challenge-note';

  // Fun: quizzes
  static const String quizTypes = '/quiz-types';
  static const String quizzes = '/quizzes';
  static const String questions = '/questions';
  static const String submitQuiz = '/submit';

  // Personal training / My skills
  static const String personalTrainingSession = '/personal-training-session';
  static const String favourites = '/favourites';

  // Coach
  static const String allocatedTrainings = '/allocated-trainings';
  static const String allocatedTrainingCompleted =
      '/allocated-training-completed';
  static const String checkCoachConnection = '/check-coach-connection';
  static const String myConnectedCoaches = '/my-connected-coaches';
  static const String disconnectCoach = '/disconnect-coach';
  static const String sendInvitationToCoach = '/send-invitation-to-coach';

  // Trophies
  static const String trophies = '/trophies';
  static const String redeemTrophy = '/redeem-trophy';

  // Settings / contact
  static const String myPlanHistory = '/my-plan-history';
  static const String changePassword = '/change-password';
  static const String contactUs = '/contact-us';

  // Notes / notifications / profile / chat
  static const String allChallengeNotes = '/all-challenge-notes';
  static const String allSkillNotes = '/all-skill-notes';
  static const String getNotifications = '/get-notifications';
  static const String markNotification = '/mark-notification';
  static const String markAllNotifications = '/mark-all-notifications';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String sendMessage = '/send-message';
  static const String openChat = '/open-chat';

  // Rating tracker
  static const String ratingTrackerList = '/rating-tracker-list';
  static const String canAddMatch = '/can-add-match';
  static const String ratingTrackerDetail = '/rating-tracker-detail';
  static const String ratingTracker = '/rating-tracker';
  static const String updateRatingTracker = '/update-rating-tracker';
  static const String deleteRatingTracker = '/delete-rating-tracker';

  // Points / trophies history
  static const String pointsHistory = '/points-history';
  static const String redeemHistory = '/redeem-history';

  // Take a tour (public)
  static const String tourVideos = '/tour-videos';
}
