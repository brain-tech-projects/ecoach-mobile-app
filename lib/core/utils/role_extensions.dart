import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';

/// Role switch used by the dashboard, tab bar and menu.
/// The value comes from `user.role` of the login response ("Coach" / "Player" / "Parent").
/// If the backend ever sends the role under another key, change it here only.
extension UserRoleX on UserModel {
  bool get isCoach => role?.trim().toLowerCase() == 'coach';
}

extension SessionRoleX on SessionService {
  bool get isCoach => user.value?.isCoach ?? false;
}

/// True when a coach is signed in (safe to call before the session exists).
bool get isCoachSession =>
    Get.isRegistered<SessionService>() && Get.find<SessionService>().isCoach;
