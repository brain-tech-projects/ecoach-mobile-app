import 'package:get/get.dart';

import 'package:ecoach_pro/features/subscription/presentation/controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  SubscriptionBinding();

  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(SubscriptionController.new);
  }
}
