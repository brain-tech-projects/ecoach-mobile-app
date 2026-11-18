import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/subscription/data/subscription_repository.dart';
import 'package:ecoach_pro/features/subscription/domain/entities/subscription_plan.dart';
import 'package:ecoach_pro/features/subscription/presentation/pages/stripe_checkout_page.dart';

/// Plans screen: plans + current plan from the API, Stripe checkout,
/// "Cancel auto-renewal" and the "Payment Successful" state.
class SubscriptionController extends GetxController {
  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  final Rxn<MyPlan> myPlan = Rxn<MyPlan>();
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  /// Plan whose checkout is being created (button spinner).
  final RxnString busyPlan = RxnString();
  final RxBool verifying = false.obs;
  final Rxn<PaymentResult> success = Rxn<PaymentResult>();

  /// "Cancel auto-renewal? ..." box is open / request running.
  final RxBool confirmingCancel = false.obs;
  final RxBool cancelling = false.obs;

  SubscriptionRepository get _repo => Get.find<SubscriptionRepository>();

  bool get trialEligible => myPlan.value?.trialEligible ?? !(myPlan.value?.isSubscribed ?? false);

  int get trialDays => plans.isEmpty ? 7 : plans.first.trialDays;

  List<String> featuresOf(SubscriptionPlan plan) => plan.features.isEmpty ? SubscriptionPlans.features : plan.features;

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) loading.value = true;
    errorMessage.value = null;
    try {
      final signedIn = MainNav.isLoggedIn;
      final results = await Future.wait<Object?>(<Future<Object?>>[
        _repo.fetchPlans(),
        if (signedIn) _repo.fetchMyPlan(),
      ]);
      plans.assignAll(results[0] as List<SubscriptionPlan>);
      myPlan.value = signedIn ? results[1] as MyPlan : null;
    } catch (e, st) {
      AppLogger.error('Subscription load failed', error: e, stackTrace: st);
      if (plans.isEmpty) errorMessage.value = e is ApiException ? e.message : 'Could not load the plans. Please try again.';
    } finally {
      loading.value = false;
    }
  }

  /// Label of the button inside a plan card (API text first).
  String buttonLabel() {
    final text = myPlan.value?.buttonText ?? '';
    if (text.isNotEmpty) return text;
    return trialEligible ? 'Start my free trial' : 'Subscribe now';
  }

  /// "Subscribe now" / "Start my free trial".
  Future<void> subscribe(SubscriptionPlan plan) async {
    if (busyPlan.value != null || verifying.value) return;
    if (myPlan.value?.isSubscribed ?? false) {
      AppToast.info('You already have an active plan.');
      return;
    }
    if (!MainNav.requireLogin()) return;

    busyPlan.value = plan.id;
    CheckoutSession checkout;
    try {
      checkout = await _repo.startCheckout(plan);
    } catch (e, st) {
      AppLogger.error('Checkout failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not start the payment. Please try again.');
      return;
    } finally {
      busyPlan.value = null;
    }

    final sessionId = await Get.to<String>(
      () => StripeCheckoutPage(
        url: checkout.url,
        successUrl: SubscriptionRepository.successUrl,
        cancelUrl: SubscriptionRepository.cancelUrl,
        fallbackSessionId: checkout.sessionId,
      ),
    );
    if (sessionId == null || sessionId.isEmpty) {
      // Cancelled or closed: the plan may still have changed in the background.
      load(silent: true);
      return;
    }
    await _verify(sessionId);
  }

  Future<void> _verify(String sessionId) async {
    verifying.value = true;
    try {
      final result = await _repo.verifySession(sessionId);
      success.value = result;
      final user = await _repo.fetchProfile();
      if (user != null) await Get.find<SessionService>().updateUser(user);
    } catch (e, st) {
      AppLogger.error('Payment verification failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'We could not confirm your payment. Please check your plan again in a moment.');
      load(silent: true);
    } finally {
      verifying.value = false;
    }
  }

  void goHome() => Get.offAllNamed<void>(AppRoutes.dashboard);

  void askCancel() => confirmingCancel.value = true;

  void keepPlan() => confirmingCancel.value = false;

  Future<void> confirmCancel() async {
    if (cancelling.value) return;
    cancelling.value = true;
    try {
      final until = await _repo.cancelAutoRenewal();
      AppToast.success('Auto-renewal cancelled successfully');
      final current = myPlan.value;
      if (current != null) {
        myPlan.value = current.copyWith(autoRenew: false, isCanceled: true, accessUntil: until.isEmpty ? null : until);
      }
      confirmingCancel.value = false;
      load(silent: true);
    } catch (e, st) {
      AppLogger.error('Cancel auto-renewal failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not cancel auto-renewal. Please try again.');
    } finally {
      cancelling.value = false;
    }
  }
}
