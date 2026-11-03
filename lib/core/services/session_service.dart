import 'package:get/get.dart';

import 'package:ecoach_pro/core/storage/token_storage.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';

/// App-wide auth state. Everything that depends on "is the user signed in?"
/// reads [isLoggedIn]. The session survives app restarts (token + user are
/// stored by [TokenStorage]).
class SessionService extends GetxService {
  SessionService(this._tokens) {
    _restore();
  }

  final TokenStorage _tokens;

  final RxBool isLoggedIn = false.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();

  void _restore() {
    final json = _tokens.userJson;
    if (_tokens.token != null && json != null) {
      user.value = UserModel.fromJson(json);
      isLoggedIn.value = true;
    }
  }

  Future<void> start({
    required String token,
    required UserModel userModel,
  }) async {
    await _tokens.save(token: token, user: userModel.toJson());
    user.value = userModel;
    isLoggedIn.value = true;
  }

  Future<void> clear() async {
    await _tokens.clear();
    user.value = null;
    isLoggedIn.value = false;
  }
}
