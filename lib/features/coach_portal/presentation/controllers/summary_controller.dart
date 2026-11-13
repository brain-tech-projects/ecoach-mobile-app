import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

class SummaryController extends GetxController {
  final RxList<SummaryRow> rows = <SummaryRow>[].obs;
  final RxString season = CoachPortalRepository.seasons.first.obs;
  final RxBool loading = true.obs;

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      rows.assignAll(await _repo.fetchSummary(season.value));
    } catch (e, st) {
      AppLogger.error('Summary failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  void selectSeason(String v) {
    if (v == season.value) return;
    season.value = v;
    load();
  }
}
