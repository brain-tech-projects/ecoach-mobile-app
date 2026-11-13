import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_dialogs.dart';

class ProgramsController extends GetxController {
  final RxList<TrainingProgram> programs = <TrainingProgram>[].obs;
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
      programs.assignAll(await _repo.fetchPrograms());
    } catch (e, st) {
      AppLogger.error('Programs load failed', error: e, stackTrace: st);
      errorMessage.value = e is ApiException ? e.message : 'Could not load your training programs.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> openAdd() async {
    await Get.toNamed<void>(AppRoutes.coachAddTraining);
    load(silent: true);
  }

  Future<void> addPlayers(TrainingProgram p) async {
    if (await CoachDialogs.assignToProgram(p)) load(silent: true);
  }

  Future<void> edit(TrainingProgram p) async {
    if (await CoachDialogs.renameProgram(p)) load(silent: true);
  }

  Future<void> remove(TrainingProgram p) async {
    if (!await CoachDialogs.confirm('Remove Program', 'Are you sure you want to remove "${p.title}"?')) return;
    if (await coachRun(() => _repo.deleteProgram(p.id), success: 'Program removed successfully')) {
      programs.removeWhere((e) => e.id == p.id);
    }
  }
}
