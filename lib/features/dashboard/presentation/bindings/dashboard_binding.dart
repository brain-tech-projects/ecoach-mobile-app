import 'package:get/get.dart';

import 'package:ecoach_pro/features/dashboard/data/repositories/dummy_dashboard_repository.dart';
import 'package:ecoach_pro/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:ecoach_pro/features/dashboard/presentation/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  DashboardBinding();

  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(DummyDashboardRepository.new);
    Get.put<DashboardController>(
      DashboardController(Get.find<DashboardRepository>()),
    );
  }
}
