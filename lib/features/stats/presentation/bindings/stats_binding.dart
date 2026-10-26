import 'package:get/get.dart';

import 'package:ecoach_pro/features/stats/data/repositories/dummy_stats_repository.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/rating_tracker_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_room_controller.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatsRepository>(DummyStatsRepository.new);
    Get.lazyPut<TrophyRoomController>(
      () => TrophyRoomController(Get.find<StatsRepository>()),
    );
    Get.lazyPut<RatingTrackerController>(
      () => RatingTrackerController(Get.find<StatsRepository>()),
    );
  }
}
