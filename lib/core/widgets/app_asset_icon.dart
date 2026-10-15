import 'package:flutter/material.dart';

/// A white-mask PNG icon tinted with [color]. Sizes are in logical points.
class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon(
    this.asset, {
    super.key,
    required this.width,
    required this.height,
    this.color = Colors.white,
  });

  final String asset;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}
