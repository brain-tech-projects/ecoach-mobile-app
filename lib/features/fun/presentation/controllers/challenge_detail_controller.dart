import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/fun/domain/entities/fun_entities.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';

/// One challenge: starts as the grid item and is refreshed from
/// `/challenge-details` (which also answers "Subscription required").
class ChallengeDetailController extends GetxController {
  ChallengeDetailController(this._repository);

  final FunRepository _repository;

  late final Rx<Challenge> challenge = Rx<Challenge>(Get.arguments as Challenge);
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    errorMessage.value = null;
    try {
      final res = await _repository.fetchChallenge(challenge.value.id);
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      final d = res.data;
      if (!res.success || d == null) {
        errorMessage.value = res.message;
        return;
      }
      challenge.value = challenge.value.copyWith(
        title: d.title.isEmpty ? null : d.title,
        videoUrl: d.videoUrl.isEmpty ? null : d.videoUrl,
        thumbnail: d.thumbnail.isEmpty ? null : d.thumbnail,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Challenge load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load this challenge.';
    }
  }
}
