import 'package:get/get.dart';

import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/subscription/domain/entities/subscription_plan.dart';

class SubscriptionController extends GetxController {
  final List<SubscriptionPlan> plans = SubscriptionPlans.all;
  final List<String> features = SubscriptionPlans.features;

  /// TODO(stripe): start the Stripe checkout for [plan] (7 day free trial).
  void onPlanTap(SubscriptionPlan plan) =>
      AppToast.info('Payments are coming soon');
}
