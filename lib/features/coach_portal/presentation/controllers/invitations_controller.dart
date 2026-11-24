// import 'package:get/get.dart';

// import 'package:ecoach_pro/core/utils/logger.dart';
// import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
// import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
// import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
// import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

// class InvitationsController extends GetxController {
//   final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
//   final RxList<PlayerInvitation> invitations = <PlayerInvitation>[].obs;
//   final RxBool loading = true.obs;

//   CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

//   @override
//   void onReady() {
//     super.onReady();
//     load();
//   }

//   Future<void> load() async {
//     loading.value = players.isEmpty && invitations.isEmpty;
//     try {
//       players.assignAll(await _repo.fetchPlayers());
//       invitations.assignAll(await _repo.fetchInvitations());
//     } catch (e, st) {
//       AppLogger.error('Invitations failed', error: e, stackTrace: st);
//     } finally {
//       loading.value = false;
//     }
//   }

//   Future<void> invite() async {
//     if (await CoachDialogs.invitePlayer()) load();
//   }

//   Future<void> disconnect(CoachPlayer p) async {
//     if (!await CoachDialogs.confirm('Disconnect Player', 'Disconnect ${p.name} from your team?')) return;
//     if (await coachRun(() => _repo.disconnectPlayer(p.id), success: 'Player disconnected')) load();
//   }

//   Future<void> respond(PlayerInvitation i, {required bool accept}) async {
//     if (await coachRun(() => _repo.respondInvitation(i.id, accept: accept), success: accept ? 'Invitation accepted' : 'Invitation rejected')) load();
//   }
// }




import 'package:ecoach_pro/features/coach_portal/data/coach_sync.dart';
import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

class InvitationsController extends GetxController with CoachAutoRefresh {
  @override
  String get syncRoute => AppRoutes.coachInvitations;

  @override
  Future<void> syncReload() => load();

  final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
  final RxList<PlayerInvitation> invitations = <PlayerInvitation>[].obs;
  final RxBool loading = true.obs;

  /// Invitation being answered (its buttons show a spinner, no double taps).
  final RxnInt respondingId = RxnInt();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onReady() {
    super.onReady();
    startAutoRefresh();
    load();
  }

  Future<void> load() async {
    markLoaded();
    loading.value = players.isEmpty && invitations.isEmpty;
    try {
      final results = await Future.wait<Object>(<Future<Object>>[_repo.fetchConnectedPlayers(), _repo.fetchInvitations()]);
      players.assignAll(results[0] as List<CoachPlayer>);
      invitations.assignAll(results[1] as List<PlayerInvitation>);
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
    if (respondingId.value != null) return;
    respondingId.value = i.id;
    try {
      if (await coachRun(() => _repo.respondInvitation(i.id, accept: accept), success: accept ? 'Invitation accepted' : 'Invitation rejected')) await load();
    } finally {
      respondingId.value = null;
    }
  }

  @override
  void onClose() {
    stopAutoRefresh();
    super.onClose();
  }
}