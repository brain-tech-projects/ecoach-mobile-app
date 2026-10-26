import 'package:flutter/foundation.dart';

@immutable
class MenuItem {
  const MenuItem({
    required this.label,
    required this.iconAsset,
    required this.route,
  });

  final String label;
  final String iconAsset;
  final String route;
}
