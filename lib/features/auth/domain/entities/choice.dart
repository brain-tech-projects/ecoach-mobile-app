import 'package:flutter/foundation.dart';

@immutable
class ChoiceOption {
  const ChoiceOption({required this.id, required this.label, this.iconAsset});

  final String id;
  final String label;
  final String? iconAsset;
}

/// A question with selectable options (single or multiple choice).
@immutable
class ChoiceQuestion {
  const ChoiceQuestion({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.multiple,
  });

  final String title;
  final String subtitle;
  final List<ChoiceOption> options;
  final bool multiple;
}
