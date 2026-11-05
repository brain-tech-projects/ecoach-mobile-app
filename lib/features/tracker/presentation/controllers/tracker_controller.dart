import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';

/// Rating Tracker: player summary + matches grouped by year.
class TrackerController extends GetxController {
  TrackerController(this._repository);

  final TrackerRepository _repository;

  final Rxn<TrackerData> data = Rxn<TrackerData>();
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxInt selectedYear = 0.obs;
  final RxSet<String> expanded = <String>{}.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repository.fetchTracker();
      if (!res.success || res.data == null) throw Exception(res.message);
      data.value = res.data;
      final years = res.data!.years;
      if (years.isNotEmpty && !years.contains(selectedYear.value)) {
        selectedYear.value = years.first;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Tracker load failed', error: error, stackTrace: stackTrace);
      if (data.value == null) errorMessage.value = 'Could not load your tracker.';
    } finally {
      loading.value = false;
    }
  }

  List<MatchEntry> get visibleEntries {
    final d = data.value;
    if (d == null) return const <MatchEntry>[];
    return d.entries.where((e) => e.playedOn.year == selectedYear.value).toList();
  }

  void toggle(String id) {
    if (!expanded.remove(id)) expanded.add(id);
  }

  Future<void> openAdd() async {
    await Get.toNamed<void>(AppRoutes.matchRating);
    await load(silent: true);
  }

  Future<void> openEdit(MatchEntry entry) async {
    await Get.toNamed<void>(AppRoutes.matchRating, arguments: entry);
    await load(silent: true);
  }

  Future<void> deleteMatch(MatchEntry entry) async {
    final yes = await Get.dialog<bool>(
      CompleteDialog(
        title: 'Delete Match',
        message: 'Are you sure you want to delete your rating of the match against '
            '${entry.opponent}?',
      ),
      barrierColor: const Color(0xB3000000),
    );
    if (yes != true) return;
    try {
      final res = await _repository.deleteMatch(entry.id);
      if (!res.success) throw Exception(res.message);
      expanded.remove(entry.id);
      await load(silent: true);
      AppToast.success('Match deleted');
    } catch (error, stackTrace) {
      AppLogger.error('Delete match failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not delete the match. Please try again.');
    }
  }
}
