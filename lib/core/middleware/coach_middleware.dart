import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/role_extensions.dart';

/// Coach-only pages: anyone else (player / parent / deep link) goes to Home.
class CoachMiddleware extends GetMiddleware {
  CoachMiddleware({super.priority = 2});

  @override
  RouteSettings? redirect(String? route) =>
      isCoachSession ? null : const RouteSettings(name: AppRoutes.dashboard);
}
