import 'package:flutter/foundation.dart';

/// The screens of the sign-up flow.
enum SignUpStepKind {
  role,
  age,
  positions,
  level,
  improve,
  difference,
  frequency,
  account,
}

/// Title + subtitle shown above a step.
@immutable
class StepHeader {
  const StepHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
