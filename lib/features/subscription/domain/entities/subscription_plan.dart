import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.weeklyPrice,
    required this.billingNote,
    this.mostPopular = false,
    this.apiName = '',
    this.currency = 'INR',
    this.interval = 'month',
    this.intervalCount = 1,
    this.trialDays = 7,
    this.features = const <String>[],
  });

  final String id;
  final String title; // QUARTERLY
  final String weeklyPrice; // ₹143.10
  final String billingNote; // ₹1860.36 every 3 months
  final bool mostPopular;

  /// Plan name the API expects at checkout ("Quarterly").
  final String apiName;
  final String currency;
  final String interval;
  final int intervalCount;
  final int trialDays;
  final List<String> features;
}

/// The signed-in user's plan (`/my-plan`).
@immutable
class MyPlan {
  const MyPlan({
    this.trialEligible = false,
    this.buttonText = '',
    this.subtitleText,
    this.planName = '',
    this.status = '',
    this.hasAccess = false,
    this.autoRenew = false,
    this.isCanceled = false,
    this.isTrial = false,
    this.accessUntil = '',
    this.nextBilling = '',
  });

  /// Eligible for the free trial (no plan yet).
  final bool trialEligible;

  /// Label the backend wants on the button ("Subscribe now", "Start my free trial").
  final String buttonText;

  /// "after free trial" while eligible.
  final String? subtitleText;
  final String planName;
  final String status;
  final bool hasAccess;
  final bool autoRenew;
  final bool isCanceled;
  final bool isTrial;

  /// Display dates ("17 Feb 2027").
  final String accessUntil;
  final String nextBilling;

  /// Has a plan that still gives access.
  bool get isSubscribed => hasAccess && planName.isNotEmpty;

  /// Renewal switched off: access ends on [accessUntil].
  bool get renewalOff => isCanceled || !autoRenew;

  bool isCurrent(SubscriptionPlan plan) => isSubscribed && planName.toLowerCase() == plan.apiName.toLowerCase();

  MyPlan copyWith({bool? autoRenew, bool? isCanceled, String? accessUntil}) => MyPlan(
    trialEligible: trialEligible,
    buttonText: buttonText,
    subtitleText: subtitleText,
    planName: planName,
    status: status,
    hasAccess: hasAccess,
    autoRenew: autoRenew ?? this.autoRenew,
    isCanceled: isCanceled ?? this.isCanceled,
    isTrial: isTrial,
    accessUntil: accessUntil ?? this.accessUntil,
    nextBilling: nextBilling,
  );
}

class CheckoutSession {
  const CheckoutSession({required this.url, required this.sessionId});
  final String url;
  final String sessionId;
}

class PaymentResult {
  const PaymentResult({required this.planName});
  final String planName;
}

/// "2026-11-24 13:22:09" / ISO -> "24 Nov 2026" ('' when unknown).
String formatPlanDate(Object? raw) {
  final text = (raw ?? '').toString().trim();
  if (text.isEmpty) return '';
  var t = DateTime.tryParse(text.replaceFirst(' ', 'T'));
  if (t == null) return '';
  if (t.isUtc) t = t.toLocal();
  const m = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${t.day} ${m[t.month - 1]} ${t.year}';
}

/// Shown while the plan list has no features of its own.
abstract final class SubscriptionPlans {
  static const List<String> features = <String>[
    'Full training programmes',
    'Individual skills',
    'Match tracker',
    'Challenges & quizzes',
    'Cancel anytime',
  ];
}
