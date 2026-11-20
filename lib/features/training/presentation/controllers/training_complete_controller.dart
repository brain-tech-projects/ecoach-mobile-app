import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// Arguments of the "Training Complete" page.
class TrainingCompleteArgs {
  const TrainingCompleteArgs({
    required this.levelId,
    required this.videoId,
    required this.nextTitle,
  });

  final int levelId;
  final int videoId;

  /// Title of the next video ("Fundamental #3"), null when this is the last.
  final String? nextTitle;
}

/// "Have you completed this training?" -> Yes / Not yet -> Okay.
class TrainingCompleteController extends GetxController {
  TrainingCompleteController(this._repository);

  final TrainingRepository _repository;

  final TrainingCompleteArgs args = Get.arguments as TrainingCompleteArgs;

  /// true = "Yes, let's do it!" (default), false = "Not yet...".
  final RxBool completed = true.obs;
  final RxBool isSubmitting = false.obs;

  void select({required bool yes}) {
    if (isSubmitting.value) return;
    completed.value = yes;
  }

  /// "Okay": Yes -> mark the video completed and return the days until the
  /// next one unlocks (null = unlocked now). Not yet -> just go back.
  Future<({bool done, int? days})> submit() async {
    if (isSubmitting.value) return (done: false, days: null);
    if (!completed.value) return (done: false, days: null);

    isSubmitting.value = true;
    try {
      final res = await _repository.completeVideo(args.videoId);
      if (!res.success) {
        AppToast.error(res.message);
        return (done: false, days: null);
      }
      // The next video's countdown comes from the refreshed list.
      int? days;
      final list = await _repository.fetchVideos(args.levelId);
      if (list.success) {
        final videos = list.data ?? const [];
        final i = videos.indexWhere((v) => v.id == args.videoId);
        if (i != -1 && i + 1 < videos.length && videos[i + 1].locked) {
          days = videos[i + 1].availableAfterDays;
        }
      }
      return (done: true, days: days);
    } catch (error, stackTrace) {
      AppLogger.error('Training complete failed', error: error, stackTrace: stackTrace);
      AppToast.error('Something went wrong. Please try again.');
      return (done: false, days: null);
    } finally {
      isSubmitting.value = false;
    }
  }
}
