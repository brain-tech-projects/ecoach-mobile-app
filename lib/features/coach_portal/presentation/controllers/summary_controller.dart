import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

class SummaryController extends GetxController {
  final RxList<SummaryRow> rows = <SummaryRow>[].obs;
  final RxString season = CoachPortalRepository.seasons.first.obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool silent = false}) async {
    final requested = season.value;
    if (!silent) loading.value = true;
    errorMessage.value = null;
    try {
      final list = await _repo.fetchSummary(requested);
      // A slower answer for a season that is no longer selected is dropped.
      if (requested == season.value) rows.assignAll(list);
    } catch (e, st) {
      AppLogger.error('Summary failed', error: e, stackTrace: st);
      if (requested == season.value) {
        rows.clear();
        errorMessage.value = e is ApiException ? e.message : 'Could not load the summary.';
      }
    } finally {
      if (requested == season.value) loading.value = false;
    }
  }

  void selectSeason(String v) {
    if (v == season.value) return;
    season.value = v;
    rows.clear();
    load();
  }
}
