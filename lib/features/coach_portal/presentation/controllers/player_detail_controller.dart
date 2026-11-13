import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

/// Player detail (arguments: CoachPlayer).
class PlayerDetailController extends GetxController {
  final CoachPlayer player = Get.arguments as CoachPlayer;
  final Rx<PlayerStats> stats = const PlayerStats().obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      stats.value = await Get.find<CoachPortalRepository>().fetchPlayerStats(player.id);
    } catch (e, st) {
      AppLogger.error('Player stats failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  Future<void> notify() => CoachDialogs.notifyPlayers(preselected: player);
}
