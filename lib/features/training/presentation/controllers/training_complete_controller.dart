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
  /// Shown until `/next-training-video` answers.
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

  /// "NEXT UP: ..." title, from `/next-training-video`.
  late final RxnString nextTitle = RxnString(args.nextTitle);
  final RxBool isLoadingNext = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNextVideo();
  }

  /// Called when the page opens: `POST /next-training-video {id}`.
  Future<void> loadNextVideo() async {
    isLoadingNext.value = true;
    try {
      final res = await _repository.fetchNextVideo(args.videoId);
      if (res.success && res.data != null) {
        nextTitle.value = res.data!.nextTitle;
      } else if (!res.success) {
        AppLogger.error('Next training video failed: ${res.message}');
      }
    } catch (error, stackTrace) {
      AppLogger.error('Next training video failed', error: error, stackTrace: stackTrace);
    } finally {
      isLoadingNext.value = false;
    }
  }

  void select({required bool yes}) {
    if (isSubmitting.value) return;
    completed.value = yes;
  }

  /// "Okay" with "Yes, let's do it!": `POST /mark-video-completed`.
  /// Returns the backend's `available_in` ("2 days"); null = unlocked now.
  /// "Not yet" -> nothing to save.
  Future<({bool done, String? availableIn})> submit() async {
    if (isSubmitting.value) return (done: false, availableIn: null);
    if (!completed.value) return (done: false, availableIn: null);

    isSubmitting.value = true;
    try {
      final res = await _repository.markVideoCompleted(args.videoId);
      if (!res.success) {
        AppToast.error(res.message);
        return (done: false, availableIn: null);
      }
      return (done: true, availableIn: res.data);
    } catch (error, stackTrace) {
      AppLogger.error('Training complete failed', error: error, stackTrace: stackTrace);
      AppToast.error('Something went wrong. Please try again.');
      return (done: false, availableIn: null);
    } finally {
      isSubmitting.value = false;
    }
  }
}
