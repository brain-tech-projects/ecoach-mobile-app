import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/share_service.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/challenge_notes_dialog.dart';

class ChallengesController extends GetxController {
  ChallengesController(this._repository);

  final FunRepository _repository;

  final RxList<Challenge> challenges = <Challenge>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Set<String> _busy = <String>{};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final res = await _repository.fetchChallenges();
    if (res.isSubscriptionRequired) {
      Get.offNamed<void>(AppRoutes.subscription);
      return;
    }
    if (res.success && res.data != null) {
      challenges.assignAll(res.data!);
    } else {
      errorMessage.value = res.message.isEmpty
          ? 'Could not load challenges.'
          : res.message;
    }
    isLoading.value = false;
  }

  void _replace(Challenge c) {
    final i = challenges.indexWhere((x) => x.id == c.id);
    if (i != -1) challenges[i] = c;
  }

  /// Optimistic toggle; reverts when the request fails.
  Future<void> toggleFavorite(Challenge c) async {
    if (!_busy.add(c.id)) return;
    final next = !c.isFavorite;
    _replace(c.copyWith(isFavorite: next));
    final res = await _repository.setFavorite(c.id, next);
    if (!res.success) {
      _replace(c);
      if (res.isSubscriptionRequired) {
        Get.toNamed<void>(AppRoutes.subscription);
      } else {
        AppToast.error(
          res.message.isEmpty ? 'Could not update favourite.' : res.message,
        );
      }
    } else if (res.message.isNotEmpty) {
      AppToast.success(res.message);
    }
    _busy.remove(c.id);
  }

  void open(Challenge c) =>
      Get.toNamed<void>(AppRoutes.challengeDetail, arguments: c);

  /// Notes popup (list / add / edit / delete through the notes API).
  void addNote(Challenge c) => showChallengeNotesDialog(c);

  Future<void> share(Challenge c, {Rect? origin}) => ShareService.shareText(
    'Take on the "${c.title}" challenge in eCoach Pro!\n${c.videoUrl}',
    origin: origin,
  );
}
