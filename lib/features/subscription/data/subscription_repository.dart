import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';
import 'package:ecoach_pro/features/subscription/domain/entities/subscription_plan.dart';

/// Plans, current plan and Stripe checkout. Talks to [ApiService] only.
class SubscriptionRepository {
  SubscriptionRepository({ApiService? api}) : _api = api ?? Get.find<ApiService>();

  final ApiService _api;

  /// Stripe sends the user back here; the checkout page intercepts these.
  static const String successUrl = 'https://ecoach.etrueconcept.com/payment-success';
  static const String cancelUrl = 'https://ecoach.etrueconcept.com/payment-cancel';

  static String _s(Object? v) => (v ?? '').toString();
  static int _i(Object? v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final res = requireSuccess(await _api.getPlans());
    final list = res.data is List ? res.data as List : const <dynamic>[];
    return <SubscriptionPlan>[
      for (final raw in list.whereType<Map>())
        () {
          final d = Map<String, dynamic>.from(raw);
          final price = d['price'] is Map ? Map<String, dynamic>.from(d['price'] as Map) : <String, dynamic>{};
          final symbol = _s(price['symbol']);
          final count = _i(price['interval_count']) <= 0 ? 1 : _i(price['interval_count']);
          final interval = _s(price['interval']).isEmpty ? 'month' : _s(price['interval']);
          final every = count > 1 ? '$count ${interval}s' : interval;
          final features = d['trial_features'] is List ? <String>[for (final f in d['trial_features'] as List) _s(f)].where((e) => e.isNotEmpty).toList() : <String>[];
          final name = _s(d['name']);
          return SubscriptionPlan(
            id: _s(d['plan_id']),
            title: name.toUpperCase(),
            weeklyPrice: '$symbol${_s(price['per_week'])}',
            billingNote: '$symbol${_s(price['total_amount'])} every $every',
            mostPopular: d['is_popular'] == true,
            apiName: name,
            currency: _s(price['currency']).isEmpty ? 'INR' : _s(price['currency']),
            interval: interval,
            intervalCount: count,
            trialDays: _i(d['trial_days']) > 0 ? _i(d['trial_days']) : 7,
            features: features,
          );
        }(),
    ];
  }

  Future<MyPlan> fetchMyPlan() async {
    final res = requireSuccess(await _api.getMyPlan());
    final body = res.body ?? const <String, dynamic>{};
    final d = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;
    if (d == null) {
      return MyPlan(
        trialEligible: body['trial_eligible'] == true,
        buttonText: _s(body['button_text']),
        subtitleText: _s(body['subtitle_text']).isEmpty ? null : _s(body['subtitle_text']),
      );
    }
    final accessFormatted = _s(d['access_until_formatted']);
    return MyPlan(
      trialEligible: body['trial_eligible'] == true,
      buttonText: _s(d['button_text']),
      planName: _s(d['plan']),
      status: _s(d['status']),
      hasAccess: d['has_access'] == true,
      autoRenew: d['auto_renew'] == true,
      isCanceled: d['is_canceled'] == true,
      isTrial: d['is_trial'] == true,
      accessUntil: accessFormatted.isNotEmpty ? accessFormatted : formatPlanDate(d['access_until']),
      nextBilling: formatPlanDate(d['next_billing_date']),
    );
  }

  Future<CheckoutSession> startCheckout(SubscriptionPlan plan) async {
    final res = requireSuccess(
      await _api.createCheckoutSession(
        plan: plan.apiName,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        currency: plan.currency,
        interval: plan.interval,
        intervalCount: plan.intervalCount,
      ),
    );
    final d = res.data is Map ? res.data as Map : const <dynamic, dynamic>{};
    final url = _s(d['checkout_url']);
    if (url.isEmpty) throw ApiException('Could not start the payment. Please try again.');
    return CheckoutSession(url: url, sessionId: _s(d['session_id']));
  }

  /// Confirms the Stripe payment after the redirect.
  Future<PaymentResult> verifySession(String sessionId) async {
    final res = requireSuccess(await _api.verifyStripeSession(sessionId));
    final d = res.data is Map ? res.data as Map : const <dynamic, dynamic>{};
    return PaymentResult(planName: _s(d['plan']));
  }

  /// Switches auto-renewal off; returns the date access ends ("17 Feb 2027").
  Future<String> cancelAutoRenewal() async {
    final res = requireSuccess(await _api.cancelSubscription());
    final d = res.data is Map ? res.data as Map : const <dynamic, dynamic>{};
    return formatPlanDate(d['access_until']);
  }

  /// Fresh user (is_subscribed ...) for the session after a payment.
  Future<UserModel?> fetchProfile() async {
    final res = await _api.getProfile();
    if (!res.success || res.data is! Map) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
