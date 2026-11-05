import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/tracker/data/repositories/api_tracker_repository.dart';
import 'package:ecoach_pro/features/tracker/data/repositories/image_picker_photo_picker.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';
import 'package:ecoach_pro/features/tracker/presentation/controllers/match_form_controller.dart';
import 'package:ecoach_pro/features/tracker/presentation/controllers/tracker_controller.dart';

/// One shared repository for both tracker pages. Swap the dummy for the API
/// version here (the photo picker is registered below).
void ensureTrackerRepository() {
  if (!Get.isRegistered<TrackerRepository>()) {
    Get.put<TrackerRepository>(
      ApiTrackerRepository(Get.find<ApiService>(), Get.find<SessionService>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<MatchPhotoPicker>()) {
    Get.put<MatchPhotoPicker>(ImagePickerMatchPhotoPicker(), permanent: true);
  }
}

class TrackerBinding extends Bindings {
  @override
  void dependencies() {
    ensureTrackerRepository();
    Get.lazyPut<TrackerController>(() => TrackerController(Get.find<TrackerRepository>()));
  }
}

class MatchFormBinding extends Bindings {
  @override
  void dependencies() {
    ensureTrackerRepository();
    Get.lazyPut<MatchFormController>(
      () => MatchFormController(Get.find<TrackerRepository>(), Get.find<MatchPhotoPicker>()),
    );
  }
}
