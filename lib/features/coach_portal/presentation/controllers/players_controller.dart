import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

class PlayersController extends GetxController {
  final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
  final RxString query = ''.obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  List<CoachPlayer> get filtered {
    final q = query.value.trim().toLowerCase();
    return q.isEmpty ? players.toList() : players.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool force = true}) async {
    loading.value = players.isEmpty;
    errorMessage.value = null;
    try {
      players.assignAll(await _repo.fetchPlayers(force: force));
    } catch (e, st) {
      AppLogger.error('Players load failed', error: e, stackTrace: st);
      errorMessage.value = e is ApiException ? e.message : 'Could not load your players.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> invite() async {
    if (await CoachDialogs.invitePlayer()) load();
  }

  void openDetail(CoachPlayer player) => Get.toNamed<void>(AppRoutes.coachPlayerDetail, arguments: player);
}
