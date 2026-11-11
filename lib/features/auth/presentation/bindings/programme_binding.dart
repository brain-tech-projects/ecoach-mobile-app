import 'package:get/get.dart';

import 'package:ecoach_pro/features/auth/presentation/controllers/programme_controller.dart';

class ProgrammeBinding extends Bindings {
  ProgrammeBinding();

  @override
  void dependencies() {
    Get.lazyPut<ProgrammeController>(ProgrammeController.new);
  }
}
