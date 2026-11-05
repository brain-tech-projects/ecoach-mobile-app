import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/stats/data/repositories/api_stats_repository.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';
import 'package:ecoach_pro/features/stats/presentation/bindings/trophy_binding.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/rating_tracker_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_room_controller.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    ensureTrophyRepository();
    Get.lazyPut<StatsRepository>(() => ApiStatsRepository(Get.find<ApiService>()));
    Get.lazyPut<TrophyRoomController>(
      () => TrophyRoomController(
        Get.find<StatsRepository>(),
        Get.find<TrophyRepository>(),
      ),
    );
    Get.lazyPut<RatingTrackerController>(
      () => RatingTrackerController(Get.find<StatsRepository>()),
    );
  }
}
