import 'package:get/get.dart';

import 'package:ecoach_pro/features/contact/presentation/controllers/contact_controller.dart';

class ContactBinding extends Bindings {
  ContactBinding();

  @override
  void dependencies() {
    Get.lazyPut<ContactController>(ContactController.new);
  }
}
