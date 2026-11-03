import 'package:get/get.dart';

import 'package:ecoach_pro/features/stats/domain/entities/point_history_entry.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/stats_repository.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';

/// "Points History" / "My Trophies" tabs.
/// Open with `arguments: 0` (history) or `arguments: 1` (my trophies).
class TrophyRoomController extends GetxController {
  TrophyRoomController(this._repository, this._trophies) {
    final arg = Get.arguments;
    if (arg == 0 || arg == 1) selectedTab.value = arg as int;
  }

  final StatsRepository _repository;
  final TrophyRepository _trophies;
  final RxList<PointHistoryEntry> history = <PointHistoryEntry>[].obs;
  final RxList<MyTrophy> myTrophies = <MyTrophy>[].obs;
  final RxBool loading = true.obs;
  final RxInt selectedTab = 0.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      history.assignAll(await _repository.fetchPointHistory());
      myTrophies.assignAll(await _trophies.fetchMyTrophies());
    } finally {
      loading.value = false;
    }
  }
}
