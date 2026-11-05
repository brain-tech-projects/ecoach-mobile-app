import 'package:ecoach_pro/core/constants/api_endpoints.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/network/network_client.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';
import 'package:ecoach_pro/features/dashboard/data/models/banner_model.dart';
import 'package:ecoach_pro/features/dashboard/data/models/dashboard_details.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Every backend call of the app lives here (one method per endpoint).
/// Controllers only talk to this class; this class only talks to
/// [NetworkClient].
///
/// Add new endpoints below (and their paths in `ApiEndpoints`).
class ApiService {
  ApiService(this._network, this._session);

  final NetworkClient _network;
  final SessionService _session;

  // ---- Auth -----------------------------------------------------------------

  /// Creates the account. For players aged 12 or under the backend creates an
  /// `Inactive` user and mails an OTP to [parentGuardianEmail].
  Future<ApiResponse<UserModel>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String country,
    required String countryCode,
    int? age,
    String? parentGuardianEmail,
    List<String>? playingPosition,
    List<String>? skillLevel,
    List<String>? improveAreas,
    List<String>? biggestDifference,
    List<String>? trainingFrequency,
  }) async {
    final res = await _network.post(
      ApiEndpoints.register,
      auth: false,
      body: <String, dynamic>{
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
        'country': country,
        'country_code': countryCode,
        // Tracking keys the backend's register endpoint expects (see the
        // working Postman call). Fixed values because the app has no UTM data.
        'utm_source': 'mobile_app',
        'utm_medium': 'app',
        'utm_campaign': 'app_signup',
        'utm_content': 'app',
        'utm_term': 'app',
        'fbclid': 'none',
        'gclid': 'none',
        'landing_page': 'mobile_app',
        // Only for ages 5-12 (OTP flow). For 13+ the key must be absent,
        // otherwise the backend enters its OTP branch.
        if (parentGuardianEmail != null) 'parent_guardian_email': email,
        if (age != null) 'age': age,
        'playing_position': playingPosition ?? const <String>[],
        'skill_level': skillLevel ?? const <String>[],
        'improve_areas': improveAreas ?? const <String>[],
        'biggest_difference': biggestDifference ?? const <String>[],
        'training_frequency': trainingFrequency ?? const <String>[],
      },
    );
    return res.map<UserModel>(_user);
  }

  Future<ApiResponse<void>> resendOtp({
    required int userId,
    required String parentGuardianEmail,
  }) async {
    final res = await _network.post(
      ApiEndpoints.resendOtp,
      auth: false,
      body: <String, dynamic>{
        'user_id': userId,
        'parent_guardian_email': parentGuardianEmail,
      },
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> verifyOtp({
    required int userId,
    required String parentGuardianEmail,
    required String otp,
  }) async {
    final res = await _network.post(
      ApiEndpoints.verifyOtp,
      auth: false,
      body: <String, dynamic>{
        'user_id': userId,
        'parent_guardian_email': parentGuardianEmail,
        'otp': otp,
      },
    );
    return res.map<void>((_) => null);
  }

  /// Signs in and stores the session (token + user) on success.
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final res = await _network.post(
      ApiEndpoints.login,
      auth: false,
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final data = res.data;
    if (res.success && data is Map && data['token'] is String) {
      final user = _user(data['user']);
      if (user != null) {
        await _session.start(
          token: data['token'] as String,
          userModel: user,
        );
        return ApiResponse<UserModel>(
          success: true,
          message: res.message,
          data: user,
          statusCode: res.statusCode,
        );
      }
    }
    return ApiResponse<UserModel>(
      success: false,
      message: res.success ? 'Unexpected server response.' : res.message,
      statusCode: res.statusCode,
      errors: res.errors,
    );
  }

  Future<void> logout() => _session.clear();

  // ---- Password reset ---------------------------------------------------------

  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    final res = await _network.post(
      ApiEndpoints.forgotPassword,
      auth: false,
      body: <String, dynamic>{'email': email},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final res = await _network.post(
      ApiEndpoints.verifyResetOtp,
      auth: false,
      body: <String, dynamic>{'email': email, 'otp': otp},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _network.post(
      ApiEndpoints.resetPassword,
      auth: false,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return res.map<void>((_) => null);
  }

  // ---- Home -------------------------------------------------------------------

  /// Public. Only `Active` banners are returned.
  Future<ApiResponse<List<BannerModel>>> getBanners() async {
    final res = await _network.get(ApiEndpoints.banners, auth: false);
    return res.map<List<BannerModel>>((data) {
      if (data is! List) return const <BannerModel>[];
      return data
          .whereType<Map>()
          .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
          .where((b) => b.isActive && b.hasContent)
          .toList();
    });
  }

  /// Stats of the signed-in user (matches, trophies, points, streak).
  Future<ApiResponse<DashboardDetails>> getDetails() async {
    final res = await _network.get(ApiEndpoints.details);
    return res.map<DashboardDetails>(
      (data) => data is Map
          ? DashboardDetails.fromJson(Map<String, dynamic>.from(data))
          : null,
    );
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    final res = await _network.get(ApiEndpoints.unreadCount);
    return res.map<int>((data) {
      final v = data is Map ? data['unread_count'] : null;
      return v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
    });
  }

  // ---- Training ---------------------------------------------------------------

  /// Levels (FUNDAMENTALS, INTERMEDIATE...) + the user's current level name.
  Future<ApiResponse<TrainingOverview>> getTrainingTypes() async {
    final res = await _network.get(ApiEndpoints.trainingTypes);
    final current = res.body?['current']?.toString();
    return res.map<TrainingOverview>((data) {
      if (data is! List) return null;
      return TrainingOverview(
        levels: data
            .whereType<Map>()
            .map((e) => TrainingLevel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        currentTitle: current,
      );
    });
  }

  /// Videos of one level. Answers `Subscription required` without a plan
  /// (check `ApiResponse.isSubscriptionRequired`).
  Future<ApiResponse<List<TrainingVideo>>> getTrainingVideos(
    int trainingTypeId,
  ) async {
    final res = await _network.post(
      ApiEndpoints.trainingVideos,
      body: <String, dynamic>{'training_type_id': trainingTypeId},
    );
    return res.map<List<TrainingVideo>>((data) {
      if (data is! List) return const <TrainingVideo>[];
      return data
          .whereType<Map>()
          .map((e) => TrainingVideo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  // ---- Skills -----------------------------------------------------------------

  Future<ApiResponse<List<SkillCategory>>> getSkillTypes() async {
    final res = await _network.get(ApiEndpoints.skillTypes);
    return res.map<List<SkillCategory>>((data) {
      if (data is! List) return const <SkillCategory>[];
      return data
          .whereType<Map>()
          .map((e) => SkillCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  /// Drills of one skill area. Answers `Subscription required` without a plan.
  Future<ApiResponse<List<Drill>>> getSkillVideos(int skillTypeId) async {
    final res = await _network.post(
      ApiEndpoints.skillVideos,
      body: <String, dynamic>{'skill_type_id': skillTypeId, 'is_free': false},
    );
    return res.map<List<Drill>>((data) {
      if (data is! List) return const <Drill>[];
      return data
          .whereType<Map>()
          .map((e) => Drill.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  /// Full drill (video URL, points, focus, equipment, completed).
  Future<ApiResponse<Drill>> getSkillVideoDetails(int skillVideoId) async {
    final res = await _network.post(
      ApiEndpoints.skillVideoDetails,
      body: <String, dynamic>{'skill_video_id': skillVideoId},
    );
    return res.map<Drill>(
      (data) => data is Map
          ? Drill.fromJson(Map<String, dynamic>.from(data))
          : null,
    );
  }

  Future<ApiResponse<void>> markSkillVideoCompleted(int skillVideoId) async {
    final res = await _network.post(
      ApiEndpoints.markSkillVideoCompleted,
      body: <String, dynamic>{'skill_video_id': skillVideoId},
    );
    return res.map<void>((_) => null);
  }

  /// "Add to / remove from Personal Training Session".
  Future<ApiResponse<void>> setVideoInPersonalSession(
    int skillVideoId, {
    required bool add,
  }) async {
    final res = await _network.post(
      ApiEndpoints.addVideoToPersonalized,
      body: <String, dynamic>{
        'skill_video_id': skillVideoId,
        'action': add ? 'add' : 'remove',
      },
    );
    return res.map<void>((_) => null);
  }

  /// "Add to / remove from My Skills".
  Future<ApiResponse<void>> setVideoInMySkills(
    int skillVideoId, {
    required bool add,
  }) async {
    final res = await _network.post(
      ApiEndpoints.addSkillToPersonalized,
      body: <String, dynamic>{
        'skill_video_id': skillVideoId,
        'action': add ? 'add' : 'remove',
      },
    );
    return res.map<void>((_) => null);
  }

  // ---- Skill notes ------------------------------------------------------------

  Future<ApiResponse<List<SkillNote>>> getSkillNotes(int skillVideoId) async {
    final res = await _network.post(
      ApiEndpoints.getSkillNotes,
      body: <String, dynamic>{'skill_video_id': skillVideoId},
    );
    return res.map<List<SkillNote>>((data) {
      if (data is! List) return const <SkillNote>[];
      return data
          .whereType<Map>()
          .map((e) => SkillNote.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<ApiResponse<void>> addSkillNote(int skillVideoId, String note) async {
    final res = await _network.post(
      ApiEndpoints.storeSkillNote,
      body: <String, dynamic>{'skill_video_id': skillVideoId, 'note': note},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> updateSkillNote(int noteId, String note) async {
    final res = await _network.post(
      ApiEndpoints.updateSkillNote,
      body: <String, dynamic>{'note_id': noteId, 'note': note},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> deleteSkillNote(int noteId) async {
    final res = await _network.post(
      ApiEndpoints.deleteSkillNote,
      body: <String, dynamic>{'note_id': noteId},
    );
    return res.map<void>((_) => null);
  }

  // ---- Fun: challenges --------------------------------------------------------

  static List<T> _list<T>(Object? data, T Function(Map<String, dynamic>) build) =>
      data is List
      ? data
            .whereType<Map>()
            .map((e) => build(Map<String, dynamic>.from(e)))
            .toList()
      : <T>[];

  Future<ApiResponse<List<Challenge>>> getChallenges() async {
    final res = await _network.get(ApiEndpoints.challenges);
    return res.map<List<Challenge>>((d) => _list(d, Challenge.fromJson));
  }

  Future<ApiResponse<Challenge>> getChallengeDetails(int challengeId) async {
    final res = await _network.post(
      ApiEndpoints.challengeDetails,
      body: <String, dynamic>{'challenge_id': challengeId},
    );
    return res.map<Challenge>(
      (d) => d is Map ? Challenge.fromJson(Map<String, dynamic>.from(d)) : null,
    );
  }

  Future<ApiResponse<void>> setChallengeFavourite(
    int challengeId, {
    required bool add,
  }) async {
    final res = await _network.post(
      ApiEndpoints.toggleFavouriteChallenge,
      body: <String, dynamic>{
        'challenge_id': challengeId,
        'action': add ? 'add' : 'remove',
      },
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<List<ChallengeNote>>> getChallengeNotes(
    int challengeId,
  ) async {
    final res = await _network.post(
      ApiEndpoints.getChallengeNotes,
      body: <String, dynamic>{'challenge_id': challengeId},
    );
    return res.map<List<ChallengeNote>>((d) => _list(d, ChallengeNote.fromJson));
  }

  Future<ApiResponse<void>> addChallengeNote(
    int challengeId,
    String note,
  ) async {
    final res = await _network.post(
      ApiEndpoints.storeChallengeNote,
      body: <String, dynamic>{'challenge_id': challengeId, 'note': note},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> updateChallengeNote(int noteId, String note) async {
    final res = await _network.post(
      ApiEndpoints.updateChallengeNote,
      body: <String, dynamic>{'note_id': noteId, 'note': note},
    );
    return res.map<void>((_) => null);
  }

  Future<ApiResponse<void>> deleteChallengeNote(int noteId) async {
    final res = await _network.post(
      ApiEndpoints.deleteChallengeNote,
      body: <String, dynamic>{'note_id': noteId},
    );
    return res.map<void>((_) => null);
  }

  // ---- Fun: quizzes -----------------------------------------------------------

  Future<ApiResponse<List<QuizGroup>>> getQuizTypes() async {
    final res = await _network.get(ApiEndpoints.quizTypes);
    return res.map<List<QuizGroup>>((d) => _list(d, QuizGroup.fromJson));
  }

  Future<ApiResponse<List<QuizSummary>>> getQuizzes(int quizTypeId) async {
    final res = await _network.post(
      ApiEndpoints.quizzes,
      body: <String, dynamic>{'quiz_type_id': quizTypeId},
    );
    return res.map<List<QuizSummary>>((d) => _list(d, QuizSummary.fromJson));
  }

  Future<ApiResponse<List<QuizQuestion>>> getQuizQuestions(int quizId) async {
    final res = await _network.post(
      ApiEndpoints.questions,
      body: <String, dynamic>{'quiz_id': quizId},
    );
    return res.map<List<QuizQuestion>>((d) => _list(d, QuizQuestion.fromJson));
  }

  /// [answers]: `[{question_id, selected_answer}]` (answer = the option text).
  Future<ApiResponse<Map<String, dynamic>>> submitQuiz(
    String quizId,
    List<Map<String, String>> answers,
  ) async {
    final res = await _network.post(
      ApiEndpoints.submitQuiz,
      body: <String, dynamic>{'quiz_id': quizId, 'answers': answers},
    );
    return res.map<Map<String, dynamic>>(
      (d) => d is Map ? Map<String, dynamic>.from(d) : null,
    );
  }

  // ---- Menu sections: raw responses (repositories parse them) ------------------

  // Personal training session + My skills
  Future<ApiResponse<List<Drill>>> getPersonalTrainingSession() async {
    final res = await _network.get(ApiEndpoints.personalTrainingSession);
    return res.map<List<Drill>>((d) => _list(d, Drill.fromJson));
  }

  Future<ApiResponse<dynamic>> getFavourites() =>
      _network.get(ApiEndpoints.favourites);

  // Coach
  Future<ApiResponse<dynamic>> getAllocatedTrainings() =>
      _network.get(ApiEndpoints.allocatedTrainings);

  /// The backend route is a GET that reads a JSON body.
  Future<ApiResponse<dynamic>> completeAllocatedTraining(int id) =>
      _network.get(
        ApiEndpoints.allocatedTrainingCompleted,
        body: <String, dynamic>{'coach_training_id': id},
      );

  Future<ApiResponse<dynamic>> checkCoachConnection() =>
      _network.get(ApiEndpoints.checkCoachConnection);

  Future<ApiResponse<dynamic>> getConnectedCoaches() =>
      _network.get(ApiEndpoints.myConnectedCoaches);

  Future<ApiResponse<dynamic>> disconnectCoach(int coachId) => _network.post(
    ApiEndpoints.disconnectCoach,
    body: <String, dynamic>{'coach_id': coachId},
  );

  Future<ApiResponse<dynamic>> sendInvitationToCoach(String email) =>
      _network.post(
        ApiEndpoints.sendInvitationToCoach,
        body: <String, dynamic>{'email': email},
      );

  // Trophies
  Future<ApiResponse<dynamic>> getTrophies() =>
      _network.get(ApiEndpoints.trophies);

  Future<ApiResponse<dynamic>> redeemTrophy(int trophyId) => _network.post(
    ApiEndpoints.redeemTrophy,
    body: <String, dynamic>{'trophy_id': trophyId},
  );

  // Settings / contact
  Future<ApiResponse<dynamic>> getPlanHistory() =>
      _network.get(ApiEndpoints.myPlanHistory);

  Future<ApiResponse<dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmation,
  }) => _network.post(
    ApiEndpoints.changePassword,
    body: <String, dynamic>{
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmation,
    },
  );

  /// Public (no token needed).
  Future<ApiResponse<dynamic>> contactUs({
    required String name,
    required String email,
    required String phone,
    required String issue,
  }) => _network.post(
    ApiEndpoints.contactUs,
    auth: false,
    body: <String, dynamic>{
      'name': name,
      'email': email,
      'phone_number': phone,
      'issue': issue,
    },
  );

  // Notes / notifications
  Future<ApiResponse<dynamic>> getAllChallengeNotes() =>
      _network.get(ApiEndpoints.allChallengeNotes);

  Future<ApiResponse<dynamic>> getAllSkillNotes() =>
      _network.get(ApiEndpoints.allSkillNotes);

  Future<ApiResponse<dynamic>> getNotifications() =>
      _network.get(ApiEndpoints.getNotifications);

  Future<ApiResponse<dynamic>> markNotificationRead(int id) => _network.post(
    ApiEndpoints.markNotification,
    body: <String, dynamic>{'notification_id': id},
  );

  Future<ApiResponse<dynamic>> markAllNotificationsRead() =>
      _network.post(ApiEndpoints.markAllNotifications);

  // Profile / chat
  Future<ApiResponse<dynamic>> getProfile() =>
      _network.get(ApiEndpoints.profile);

  Future<ApiResponse<dynamic>> updateProfile(Map<String, dynamic> body) =>
      _network.post(ApiEndpoints.updateProfile, body: body);

  Future<ApiResponse<dynamic>> openChat(int receiverId) => _network.post(
    ApiEndpoints.openChat,
    body: <String, dynamic>{'receiver_id': receiverId},
  );

  Future<ApiResponse<dynamic>> sendChatMessage(int receiverId, String text) =>
      _network.post(
        ApiEndpoints.sendMessage,
        body: <String, dynamic>{'receiver_id': receiverId, 'message': text},
      );

  // ---- Rating tracker / history ------------------------------------------------

  Future<ApiResponse<dynamic>> getRatingTrackerList() =>
      _network.get(ApiEndpoints.ratingTrackerList);

  Future<ApiResponse<dynamic>> canAddMatch() =>
      _network.get(ApiEndpoints.canAddMatch);

  Future<ApiResponse<dynamic>> getRatingTrackerDetail(int id) => _network.get(
    ApiEndpoints.ratingTrackerDetail,
    query: <String, dynamic>{'id': id},
  );

  /// Create ([id] null) or update a match. A photo goes up as multipart.
  Future<ApiResponse<dynamic>> saveRatingTracker({
    int? id,
    required Map<String, dynamic> fields,
    String? photoPath,
  }) {
    final path = id == null
        ? ApiEndpoints.ratingTracker
        : ApiEndpoints.updateRatingTracker;
    if (id == null && photoPath == null) {
      return _network.post(path, body: fields);
    }
    return _network.postForm(
      path,
      fields: <String, dynamic>{if (id != null) 'id': id, ...fields},
      fileField: 'match_photo',
      filePath: photoPath,
    );
  }

  Future<ApiResponse<dynamic>> deleteRatingTracker(int id) => _network.post(
    ApiEndpoints.deleteRatingTracker,
    body: <String, dynamic>{'id': id},
  );

  Future<ApiResponse<dynamic>> getPointsHistory() =>
      _network.get(ApiEndpoints.pointsHistory);

  Future<ApiResponse<dynamic>> getRedeemHistory() =>
      _network.get(ApiEndpoints.redeemHistory);

  // ---- helpers ----------------------------------------------------------------

  static UserModel? _user(Object? data) =>
      data is Map ? UserModel.fromJson(Map<String, dynamic>.from(data)) : null;
}
