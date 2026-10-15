import 'package:flutter/foundation.dart';

/// One tile of the 2x2 stats grid ("0 / Matches tracked").
@immutable
class DashboardStat {
  const DashboardStat({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;
}
