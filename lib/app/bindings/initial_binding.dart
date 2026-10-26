import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';

/// App-wide singletons that live for the whole process.
class InitialBinding extends Bindings {
  InitialBinding(this._storage);

  final LocalStorage _storage;

  @override
  void dependencies() {
    Get.put<LocalStorage>(_storage, permanent: true);
    Get.put<SessionService>(SessionService(), permanent: true);
  }
}
