import 'package:ecoach_pro/core/config/env.dart';

/// User as returned by `register` and `login`.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.nickname,
    this.role,
    this.status,
    this.age,
    this.country,
    this.countryCode,
    this.parentGuardianEmail,
    this.profilePhoto,
    this.coverPhoto,
    this.club,
    this.myposition,
    this.isSubscribed = false,
    this.playingPosition = const <String>[],
    this.skillLevel = const <String>[],
    this.improveAreas = const <String>[],
    this.biggestDifference = const <String>[],
    this.trainingFrequency = const <String>[],
  });

  final int id;
  final String email;
  final String? fullName;
  final String? nickname;
  final String? role;
  final String? status;
  final int? age;
  final String? country;
  final String? countryCode;
  final String? parentGuardianEmail;
  final String? profilePhoto;
  final String? coverPhoto;
  final String? club;
  final String? myposition;
  final bool isSubscribed;
  final List<String> playingPosition;
  final List<String> skillLevel;
  final List<String> improveAreas;
  final List<String> biggestDifference;
  final List<String> trainingFrequency;

  /// Name to show in the UI.
  String get displayName => (nickname?.trim().isNotEmpty ?? false) ? nickname! : (fullName ?? email);

  /// Parent/guardian OTP not completed yet.
  bool get isInactive => status?.toLowerCase() == 'inactive';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _int(json['id']) ?? 0,
    email: (json['email'] ?? '').toString(),
    fullName: json['full_name'] as String?,
    nickname: json['nickname'] as String?,
    role: json['role'] as String?,
    status: json['status'] as String?,
    age: _int(json['age']),
    country: json['country'] as String?,
    countryCode: json['country_code'] as String?,
    parentGuardianEmail: json['parent_guardian_email'] as String?,
    // Relative paths (profile-photos/x.webp) become full URLs.
    profilePhoto: Env.skillMediaUrl(json['profile_photo'] as String?),
    coverPhoto: Env.skillMediaUrl(json['cover_photo'] as String?),
    club: json['my_club'] as String?,
    myposition: json['my_position'] as String?,
    isSubscribed: json['is_subscribed'] == true,
    playingPosition: _list(json['playing_position']),
    skillLevel: _list(json['skill_level']),
    improveAreas: _list(json['improve_areas']),
    biggestDifference: _list(json['biggest_difference']),
    trainingFrequency: _list(json['training_frequency']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'email': email,
    'full_name': fullName,
    'nickname': nickname,
    'role': role,
    'status': status,
    'age': age,
    'country': country,
    'country_code': countryCode,
    'parent_guardian_email': parentGuardianEmail,
    'profile_photo': profilePhoto,
    'cover_photo': coverPhoto,
    'my_club': club,
    'my_position': myposition,
    'is_subscribed': isSubscribed,
    'playing_position': playingPosition,
    'skill_level': skillLevel,
    'improve_areas': improveAreas,
    'biggest_difference': biggestDifference,
    'training_frequency': trainingFrequency,
  };

  static int? _int(Object? v) => v is int ? v : int.tryParse('${v ?? ''}');

  static List<String> _list(Object? v) => v is List ? v.map((e) => e.toString()).toList() : const <String>[];
}
