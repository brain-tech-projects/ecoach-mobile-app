import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/menu/domain/entities/menu_item.dart';

class SideMenuController extends GetxController {
  void close() => Get.back<void>();

  /// The menu is replaced by the destination, so "back" returns to the page
  /// the menu was opened from.
  void openItem(MenuItem item) => Get.offNamed<void>(item.route);

  void openLogin() => Get.offNamed<void>(AppRoutes.signIn);
}
