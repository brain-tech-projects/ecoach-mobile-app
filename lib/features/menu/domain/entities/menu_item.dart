import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum MenuAction { navigate, installApp, logout }

@immutable
class MenuItem {
  const MenuItem({
    required this.label,
    this.iconAsset,
    this.icon,
    this.route = '',
    this.action = MenuAction.navigate,
  }) : assert(iconAsset != null || icon != null);

  final String label;

  /// PNG from the design (tinted green). Use [icon] when there is no asset.
  final String? iconAsset;
  final IconData? icon;

  /// Empty = page not built yet ("Coming soon").
  final String route;
  final MenuAction action;
}
