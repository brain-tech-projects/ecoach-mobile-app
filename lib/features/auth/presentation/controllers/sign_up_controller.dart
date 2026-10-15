import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';

class SignUpController extends GetxController {
  final Rx<UserRole> selectedRole = UserRole.player.obs;

  /// Only the first step ("Who is this for?") is built so far.
  final int currentStep = 1;

  void selectRole(UserRole role) => selectedRole.value = role;

  void onNext() {
    // TODO(flow): open step 2 of the selected role's sign-up flow.
  }

  void openSignIn() => Get.offNamed<void>(AppRoutes.signIn);
}
