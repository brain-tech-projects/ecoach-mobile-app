import 'package:get/get.dart';

/// App-wide auth state. Everything that depends on "is the user signed in?"
/// reads [isLoggedIn]; the sign-in flow will set it once the API exists.
class SessionService extends GetxService {
  final RxBool isLoggedIn = false.obs;
}
