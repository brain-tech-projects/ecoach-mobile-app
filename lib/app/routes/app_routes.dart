abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String setNewPassword = '/set-new-password';
  static const String menu = '/menu';
  static const String subscription = '/subscription';
  static const String appSettings = '/app-settings';
  static const String contact = '/contact';
  static const String training = '/training';
  static const String trainingDetail = '/training-detail';
  static const String skills = '/skills';
  static const String skillList = '/skill-list';
  static const String skillDetail = '/skill-detail';
  static const String ratingTracker = '/rating-tracker';
  /// Trophy Room: points balance + all trophies to redeem.
  static const String trophyRoom = '/trophy-room';
  /// One trophy + Redeem (arguments: Trophy).
  static const String trophyRoomDetail = '/trophy-room-detail';
  /// Points History / My Trophies tabs (arguments: 0 or 1).
  static const String allTrophy = '/all-trophy';
  /// Coaches Training: skills set by the coach.
  static const String coachTraining = '/coach-training';
  /// One assigned training video (arguments: AssignedTraining).
  static const String coachTrainingDetail = '/coach-training-detail';
  /// Coach Invitation: connected coach / pending invitations.
  static const String coachInvitation = '/coach-invitation';
}
