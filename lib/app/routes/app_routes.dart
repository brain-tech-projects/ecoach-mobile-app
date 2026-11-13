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
  static const String personalTraining = '/personal-training';
  static const String trainingDetail = '/training-detail';
  static const String skills = '/skills';
  static const String fun = '/fun';
  static const String challenges = '/challenges';
  static const String challengeDetail = '/challenge-detail';
  static const String quizzes = '/quizzes';
  static const String quizList = '/quiz-list';
  static const String quizPlay = '/quiz-play';
  static const String quizReview = '/quiz-review';
  static const String skillList = '/skill-list';
  static const String skillDetail = '/skill-detail';
  static const String ratingTracker = '/rating-tracker';

  /// 13-step form to add / edit a rated match (arguments: MatchEntry? to edit).
  static const String matchRating = '/match-rating';

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

  /// Profile menu pages.
  static const String myProfile = '/my-profile';
  static const String mySkills = '/my-skills';
  static const String notes = '/notes';
  static const String chats = '/chats';
  static const String chat = '/chat';
  static const String notifications = '/notifications';

  /// Sign-up: "Generating your programme" -> "Programme is ready" (arguments: ProgrammeArgs).
  static const String programme = '/programme';

  /// Signed-out "Take a tour" videos.
  static const String tour = '/tour';

  /// Personal Training "Play All" queue player (arguments: PersonalTrainingPlayerArgs).
  static const String personalTrainingPlayer = '/personal-training-player';

  // ---- Coach portal ----
  static const String coachTeams = '/coach-teams';
  static const String coachTeamForm = '/coach-team-form';
  static const String coachPlayers = '/coach-players';
  static const String coachPlayerDetail = '/coach-player-detail';
  static const String coachPrograms = '/coach-programs';
  static const String coachAddTraining = '/coach-add-training';
  static const String coachChats = '/coach-chats';
  static const String coachSummary = '/coach-summary';
  static const String coachInvitations = '/coach-invitations';
}
