import 'package:ecoach_pro/core/constants/api_endpoints.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/network/network_client.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';
import 'package:ecoach_pro/features/dashboard/data/models/banner_model.dart';
import 'package:ecoach_pro/features/dashboard/data/models/dashboard_details.dart';
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

  // ---- helpers ----------------------------------------------------------------

  static UserModel? _user(Object? data) =>
      data is Map ? UserModel.fromJson(Map<String, dynamic>.from(data)) : null;
}
