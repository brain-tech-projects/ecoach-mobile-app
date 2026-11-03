import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.weeklyPrice,
    required this.billingNote,
    this.mostPopular = false,
  });

  final String id;
  final String title; // QUARTERLY
  final String weeklyPrice; // ₹143.10
  final String billingNote; // ₹1860.36 every 3 months
  final bool mostPopular;
}

/// There is no plans API yet, so the plans are static (same as the design).
abstract final class SubscriptionPlans {
  static const List<SubscriptionPlan> all = <SubscriptionPlan>[
    SubscriptionPlan(
      id: 'quarterly',
      title: 'QUARTERLY',
      weeklyPrice: '₹143.10',
      billingNote: '₹1860.36 every 3 months',
      mostPopular: true,
    ),
    SubscriptionPlan(
      id: 'annually',
      title: 'ANNUALLY',
      weeklyPrice: '₹134.21',
      billingNote: '₹6978.91 every year',
    ),
  ];

  static const List<String> features = <String>[
    'Full training programmes',
    'Individual skills',
    'Match tracker',
    'Challenges & quizzes',
    'Cancel anytime',
  ];
}
