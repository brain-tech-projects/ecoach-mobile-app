import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// One level: the player (or the locked preview) + the row of numbered
/// videos.
class TrainingDetailController extends GetxController {
  TrainingDetailController(this._repository);

  final TrainingRepository _repository;

  final TrainingLevel level = Get.arguments as TrainingLevel;

  final RxList<TrainingVideo> videos = <TrainingVideo>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  TrainingVideo? get current =>
      videos.isEmpty ? null : videos[currentIndex.value];

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final res = await _repository.fetchVideos(level.id);

      // No plan: replace this page with the Subscription page (back goes
      // to the level list).
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }

      final list = res.data ?? const <TrainingVideo>[];
      videos.assignAll(list);
      // Start on the first video not finished yet (or the last one).
      final next = list.indexWhere((v) => !v.completed);
      currentIndex.value = list.isEmpty ? 0 : (next == -1 ? list.length - 1 : next);
    } catch (error, stackTrace) {
      AppLogger.error('Videos load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the videos.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Locked videos can be selected too: they show the lock + countdown.
  void select(int index) => currentIndex.value = index;

  /// TODO(api): no "complete video" endpoint yet. When it exists, call it
  /// here (points + unlock) and then `load()` to refresh the list.
  void onVideoEnded() {}
}
