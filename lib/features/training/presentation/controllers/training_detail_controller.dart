import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// One level: the player + the row of numbered videos (locked / unlocked).
class TrainingDetailController extends GetxController {
  TrainingDetailController(this._repository);

  final TrainingRepository _repository;

  final TrainingLevel level = Get.arguments as TrainingLevel;

  final RxList<TrainingVideo> videos = <TrainingVideo>[].obs;
  final RxInt currentIndex = 0.obs;
  late final RxInt unlocked = level.unlocked.obs;
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
      videos.assignAll(await _repository.fetchVideos(level.id));
    } catch (error, stackTrace) {
      AppLogger.error('Videos load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the videos.';
    } finally {
      isLoading.value = false;
    }
  }

  bool isLocked(int index) => index >= unlocked.value;

  void select(int index) {
    if (isLocked(index)) {
      AppToast.info('Finish the previous video to unlock this one.');
      return;
    }
    currentIndex.value = index;
  }

  /// Finishing the newest unlocked video unlocks the next one and rewards
  /// points.
  void onVideoEnded() {
    final video = current;
    if (video == null || currentIndex.value != unlocked.value - 1) return;

    // TODO(api): send the completion to the backend (points + unlock).
    AppToast.reward(
      title: 'Training Video Completed',
      message: "You completed '${video.title}' and earned ${video.points} points!",
    );
    if (unlocked.value < level.total) unlocked.value++;
  }
}
