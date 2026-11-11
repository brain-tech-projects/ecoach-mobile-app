import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/tour/domain/entities/tour_video.dart';

/// "Take The Tour": intro videos from `GET /tour-videos`, one selected at a
/// time. Public - no login needed.
class TourController extends GetxController {
  static const String intro =
      'Watch quick videos to understand how training, skills, and progress '
      'tracking work inside the eCoach app.';

  final ApiService _api = Get.find<ApiService>();

  final RxList<TourVideo> videos = <TourVideo>[].obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  TourVideo? get selected =>
      videos.isEmpty ? null : videos[selectedIndex.value.clamp(0, videos.length - 1)];

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _api.getTourVideos();
      if (!res.success) {
        errorMessage.value = res.message;
        return;
      }
      final list = [...(res.data ?? const <TourVideo>[])]
        ..sort((a, b) => a.order.compareTo(b.order));
      videos.assignAll(list);
      selectedIndex.value = 0;
    } catch (error, stackTrace) {
      AppLogger.error('Tour load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load the tour videos.';
    } finally {
      loading.value = false;
    }
  }

  void select(int index) {
    if (index < 0 || index >= videos.length) return;
    selectedIndex.value = index;
  }
}
