import 'dart:async';

import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/personal_training/domain/entities/personal_training_player_args.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

/// "Play All": plays the personal session one video after another with
/// Previous / Next and a 3 s countdown before the next video starts.
class PersonalTrainingPlayerController extends GetxController {
  PersonalTrainingPlayerController(this._repository);

  final SkillsRepository _repository;

  static const int countdownSeconds = 3;

  late final PersonalTrainingPlayerArgs args =
      Get.arguments as PersonalTrainingPlayerArgs;

  late final RxList<Drill> drills = args.drills.toList().obs;
  late final RxInt index = args.startIndex
      .clamp(0, args.drills.isEmpty ? 0 : args.drills.length - 1)
      .toInt()
      .obs;

  /// Seconds left before the next video (null = no popup).
  final RxnInt countdown = RxnInt();
  final RxnString errorMessage = RxnString();

  Timer? _timer;

  Drill get current => drills[index.value];
  bool get hasPrevious => index.value > 0;
  bool get hasNext => index.value < drills.length - 1;

  @override
  void onReady() {
    super.onReady();
    loadDetails();
  }

  /// List items may not carry the video URL: fetch the full drill.
  Future<void> loadDetails() async {
    final drill = current;
    if (drill.videoUrl.isNotEmpty) return;
    errorMessage.value = null;
    try {
      final res = await _repository.fetchDrill(drill.id);
      if (isClosed) return;
      if (res.isSubscriptionRequired) {
        Get.offNamed<void>(AppRoutes.subscription);
        return;
      }
      if (!res.success || res.data == null) {
        if (current.id == drill.id) errorMessage.value = res.message;
        return;
      }
      final i = drills.indexWhere((d) => d.id == drill.id);
      if (i >= 0) drills[i] = drills[i].withDetails(res.data!);
    } catch (error, stackTrace) {
      AppLogger.error('Player drill load failed', error: error, stackTrace: stackTrace);
      if (!isClosed && current.id == drill.id) {
        errorMessage.value = 'Could not load this video.';
      }
    }
  }

  void goTo(int target) {
    if (target < 0 || target >= drills.length) return;
    cancelCountdown();
    errorMessage.value = null;
    index.value = target;
    loadDetails();
  }

  void next() => goTo(index.value + 1);
  void previous() => goTo(index.value - 1);

  /// Called by the video player when playback reaches the end.
  void onVideoEnded() {
    if (!hasNext) {
      AppToast.success('Personal training session completed!');
      return;
    }
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    countdown.value = countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = (countdown.value ?? 1) - 1;
      if (left <= 0) {
        t.cancel();
        countdown.value = null;
        next();
      } else {
        countdown.value = left;
      }
    });
  }

  void cancelCountdown() {
    _timer?.cancel();
    _timer = null;
    countdown.value = null;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
