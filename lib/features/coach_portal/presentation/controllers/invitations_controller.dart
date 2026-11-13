import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

class InvitationsController extends GetxController {
  final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
  final RxList<PlayerInvitation> invitations = <PlayerInvitation>[].obs;
  final RxBool loading = true.obs;

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = players.isEmpty && invitations.isEmpty;
    try {
      players.assignAll(await _repo.fetchPlayers());
      invitations.assignAll(await _repo.fetchInvitations());
    } catch (e, st) {
      AppLogger.error('Invitations failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  Future<void> invite() async {
    if (await CoachDialogs.invitePlayer()) load();
  }

  Future<void> disconnect(CoachPlayer p) async {
    if (!await CoachDialogs.confirm('Disconnect Player', 'Disconnect ${p.name} from your team?')) return;
    if (await coachRun(() => _repo.disconnectPlayer(p.id), success: 'Player disconnected')) load();
  }

  Future<void> respond(PlayerInvitation i, {required bool accept}) async {
    if (await coachRun(() => _repo.respondInvitation(i.id, accept: accept), success: accept ? 'Invitation accepted' : 'Invitation rejected')) load();
  }
}
