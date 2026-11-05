import 'package:get/get.dart';

import 'package:ecoach_pro/features/personal_training/presentation/controllers/personal_training_controller.dart';

class PersonalTrainingBinding extends Bindings {
  PersonalTrainingBinding();

  @override
  void dependencies() {
    Get.lazyPut<PersonalTrainingController>(PersonalTrainingController.new);
  }
}
