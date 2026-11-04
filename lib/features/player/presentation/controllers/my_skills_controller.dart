import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// My Skills: "All Skills" (saved drills) and "Challenges" (favourite fun
/// challenges, from `FunRepository`). Open with `arguments: 0` / `1` to pick
/// the tab.
class MySkillsController extends GetxController {
  MySkillsController(this._player, this._fun) {
    final a = Get.arguments;
    if (a == 0 || a == 1) tab.value = a as int;
  }

  final PlayerRepository _player;
  final FunRepository _fun;

  final RxInt tab = 0.obs;
  final RxList<SavedSkill> skills = <SavedSkill>[].obs;
  final RxList<Challenge> challenges = <Challenge>[].obs;
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
      skills.assignAll(await _player.fetchSavedSkills());
      final res = await _fun.fetchChallenges();
      if (!res.success) throw Exception(res.message);
      challenges.assignAll((res.data ?? const <Challenge>[]).where((c) => c.isFavorite));
    } catch (error, stackTrace) {
      AppLogger.error('My skills load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your skills.';
    } finally {
      loading.value = false;
    }
  }

  void openSkill(SavedSkill s) => Get.toNamed<void>(AppRoutes.skillDetail, arguments: s.drill);

  void openChallenge(Challenge c) => Get.toNamed<void>(AppRoutes.challengeDetail, arguments: c);

  Future<bool> _confirm(String title, String message) async =>
      await Get.dialog<bool>(
        CompleteDialog(title: title, message: message),
        barrierColor: const Color(0xB3000000),
      ) ==
      true;

  Future<void> removeSkill(SavedSkill s) async {
    if (!await _confirm('Remove Skill', 'Remove "${s.drill.title}" from My Skills?')) return;
    try {
      await _player.removeSavedSkill(s.drill.id);
      skills.removeWhere((e) => e.id == s.id);
      AppToast.success('Removed from My Skills');
    } catch (error, stackTrace) {
      AppLogger.error('Remove skill failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not remove. Please try again.');
    }
  }

  Future<void> removeChallenge(Challenge c) async {
    if (!await _confirm('Remove Challenge', 'Remove "${c.title}" from My Skills?')) return;
    try {
      final res = await _fun.setFavorite(c.id, false);
      if (!res.success) throw Exception(res.message);
      challenges.removeWhere((e) => e.id == c.id);
      AppToast.success('Removed from My Skills');
    } catch (error, stackTrace) {
      AppLogger.error('Remove challenge failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not remove. Please try again.');
    }
  }
}
