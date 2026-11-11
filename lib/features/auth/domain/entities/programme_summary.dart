import 'package:flutter/foundation.dart';

/// What the player picked during sign-up (shown on the "programme is ready"
/// screen). Values are display strings, e.g. `13+ years old`, `2× a week`.
@immutable
class ProgrammeSummary {
  const ProgrammeSummary({
    this.age = '',
    this.positions = '',
    this.level = '',
    this.focus = '',
    this.goals = '',
    this.frequency = '',
  });

  final String age;
  final String positions;
  final String level;
  final String focus;
  final String goals;
  final String frequency;
}

/// Route arguments of the programme screens. [email] / [password] are used
/// to sign in when the player taps "Unlock My Programme".
@immutable
class ProgrammeArgs {
  const ProgrammeArgs({
    required this.email,
    required this.password,
    required this.summary,
  });

  final String email;
  final String password;
  final ProgrammeSummary summary;
}
