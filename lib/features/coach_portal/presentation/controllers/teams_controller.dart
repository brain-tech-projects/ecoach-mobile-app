import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

class TeamsController extends GetxController {
  final RxList<CoachTeam> teams = <CoachTeam>[].obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    errorMessage.value = null;
    try {
      teams.assignAll(await _repo.fetchTeams());
    } catch (e, st) {
      AppLogger.error('Teams load failed', error: e, stackTrace: st);
      errorMessage.value = e is ApiException ? e.message : 'Could not load your teams.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> openAdd() async {
    await Get.toNamed<void>(AppRoutes.coachTeamForm);
    load(silent: true);
  }

  Future<void> openEdit(CoachTeam team) async {
    await Get.toNamed<void>(AppRoutes.coachTeamForm, arguments: team);
    load(silent: true);
  }

  Future<void> newGroup(CoachTeam team) async {
    if (await CoachDialogs.assignToTeam(team)) load(silent: true);
  }

  Future<void> addPlayers(CoachTeam team) async {
    if (await CoachDialogs.assignToTeam(team)) load(silent: true);
  }

  Future<void> removeTeam(CoachTeam team) async {
    if (!await CoachDialogs.confirm('Remove Team', 'Are you sure you want to remove "${team.name}"? This cannot be undone.')) return;
    if (await coachRun(() => _repo.deleteTeam(team.id), success: 'Team removed successfully')) {
      teams.removeWhere((t) => t.id == team.id);
    }
  }

  Future<void> removeGroup(CoachTeam team, TeamGroup group) async {
    if (!await CoachDialogs.confirm('Remove Group', 'Remove the group "${group.name}"? Its players stay in your team.')) return;
    if (await coachRun(() => _repo.deleteGroup(group.id), success: 'Group removed successfully')) load(silent: true);
  }
}
