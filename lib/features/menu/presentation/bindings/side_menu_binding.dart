import 'package:get/get.dart';

import 'package:ecoach_pro/features/menu/presentation/controllers/side_menu_controller.dart';

class SideMenuBinding extends Bindings {
  SideMenuBinding();

  @override
  void dependencies() {
    Get.lazyPut<SideMenuController>(SideMenuController.new);
  }
}
