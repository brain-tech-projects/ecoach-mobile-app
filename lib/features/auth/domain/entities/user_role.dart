import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';

const List<SignUpStepKind> _fullFlow = <SignUpStepKind>[
  SignUpStepKind.role,
  SignUpStepKind.age,
  SignUpStepKind.positions,
  SignUpStepKind.level,
  SignUpStepKind.improve,
  SignUpStepKind.difference,
  SignUpStepKind.frequency,
  SignUpStepKind.account,
];

const List<SignUpStepKind> _coachFlow = <SignUpStepKind>[
  SignUpStepKind.role,
  SignUpStepKind.account,
];

/// Who the account is for. [flow] is the ordered list of sign-up screens
/// (players and parents: 8 screens, coaches: 2 screens).
enum UserRole {
  player(label: 'I\'m a Player', flow: _fullFlow),
  coach(label: 'I\'m a Coach', flow: _coachFlow),
  parent(label: 'I\'m a Parent', flow: _fullFlow);

  const UserRole({required this.label, required this.flow});

  final String label;
  final List<SignUpStepKind> flow;

  int get totalSteps => flow.length;
}
