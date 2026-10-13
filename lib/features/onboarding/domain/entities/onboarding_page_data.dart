import 'package:flutter/foundation.dart';

/// One onboarding slide. A slide shows an optional [title], a stack of
/// [chips] (pill labels) and/or an optional [description] paragraph.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    this.title,
    this.chips = const <String>[],
    this.description,
  }) : assert(
         title != null || description != null,
         'A slide needs a title or a description',
       );

  final String? title;
  final List<String> chips;
  final String? description;
}