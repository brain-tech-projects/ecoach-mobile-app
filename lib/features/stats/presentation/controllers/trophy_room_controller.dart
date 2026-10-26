import 'package:get/get.dart';

import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';

class TrophyRoomController extends GetxController {
  TrophyRoomController(this._repository);

  final StatsRepository _repository;
  final RxList<PointHistoryEntry> history = <PointHistoryEntry>[].obs;
  final RxBool loading = true.obs;
  final RxInt selectedTab = 0.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    history.assignAll(await _repository.fetchPointHistory());
    loading.value = false;
  }
}
