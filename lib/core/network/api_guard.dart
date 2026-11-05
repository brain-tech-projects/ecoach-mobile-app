import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_response.dart';

/// Thrown by the API repositories; its [message] is the server's message.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Returns [res] when the call worked, otherwise throws [ApiException].
/// "Subscription required" also opens the Subscription page.
ApiResponse<T> requireSuccess<T>(ApiResponse<T> res) {
  if (res.isSubscriptionRequired) {
    if (Get.currentRoute != AppRoutes.subscription) {
      Get.toNamed<void>(AppRoutes.subscription);
    }
    throw ApiException(res.message);
  }
  if (!res.success) throw ApiException(res.message);
  return res;
}
