import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';

/// Trophy Room: current points + every trophy that can be redeemed.
class TrophyStoreController extends GetxController {
  TrophyStoreController(this._repository);

  final TrophyRepository _repository;
  final RxList<Trophy> trophies = <Trophy>[].obs;
  final RxDouble points = 0.0.obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      points.value = await _repository.fetchPoints();
      trophies.assignAll(await _repository.fetchTrophies());
    } catch (error, stackTrace) {
      AppLogger.error('Trophy room load failed',
          error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the Trophy Room.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> _refreshPoints() async {
    try {
      points.value = await _repository.fetchPoints();
    } catch (_) {/* keep the last known value */}
  }

  /// Points button of a trophy -> redeem page; points refresh on return.
  Future<void> openTrophy(Trophy trophy) async {
    await Get.toNamed<void>(AppRoutes.trophyRoomDetail, arguments: trophy);
    await _refreshPoints();
  }

  /// Top-right icon of the points card -> Points History tab.
  Future<void> openHistory() async {
    await Get.toNamed<void>(AppRoutes.allTrophy, arguments: 0);
    await _refreshPoints();
  }
}
