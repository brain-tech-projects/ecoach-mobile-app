import 'package:get/get.dart';

import 'package:ecoach_pro/features/tour/presentation/controllers/tour_controller.dart';

class TourBinding extends Bindings {
  TourBinding();

  @override
  void dependencies() {
    Get.lazyPut<TourController>(TourController.new);
  }
}
