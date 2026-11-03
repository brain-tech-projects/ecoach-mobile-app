import 'package:get/get.dart';

import 'package:ecoach_pro/features/stats/data/repositories/dummy_trophy_repository.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_detail_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_store_controller.dart';

/// One shared repository for every Trophy Room page (keeps points and
/// redeemed trophies between pages). Swap the implementation for the API.
void ensureTrophyRepository() {
  if (!Get.isRegistered<TrophyRepository>()) {
    Get.put<TrophyRepository>(DummyTrophyRepository(), permanent: true);
  }
}

class TrophyStoreBinding extends Bindings {
  @override
  void dependencies() {
    ensureTrophyRepository();
    Get.lazyPut<TrophyStoreController>(
      () => TrophyStoreController(Get.find<TrophyRepository>()),
    );
  }
}

class TrophyDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureTrophyRepository();
    Get.lazyPut<TrophyDetailController>(
      () => TrophyDetailController(Get.find<TrophyRepository>()),
    );
  }
}
