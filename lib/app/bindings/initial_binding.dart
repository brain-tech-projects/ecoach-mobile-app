import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/network_client.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';
import 'package:ecoach_pro/core/storage/token_storage.dart';

/// App-wide singletons that live for the whole process.
class InitialBinding extends Bindings {
  InitialBinding(this._storage);

  final LocalStorage _storage;

  @override
  void dependencies() {
    Get.put<LocalStorage>(_storage, permanent: true);

    final tokens = Get.put<TokenStorage>(
      TokenStorage(_storage),
      permanent: true,
    );
    final session = Get.put<SessionService>(
      SessionService(tokens),
      permanent: true,
    );
    final network = Get.put<NetworkClient>(
      NetworkClient(
        tokenStorage: tokens,
        // Token expired / revoked -> drop the session and ask to sign in.
        onUnauthorized: () async {
          await session.clear();
          if (Get.currentRoute != AppRoutes.signIn) {
            Get.offAllNamed<void>(AppRoutes.signIn);
          }
        },
      ),
      permanent: true,
    );
    Get.put<ApiService>(ApiService(network, session), permanent: true);
  }
}
