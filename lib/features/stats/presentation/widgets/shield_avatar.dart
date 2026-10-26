import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

class ShieldAvatar extends StatelessWidget {
  const ShieldAvatar({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: 78 * s,
      height: 82 * s,
      child: ClipPath(
        clipper: _ShieldClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF777F80), Color(0xFF202A2B)],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 47 * s,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..cubicTo(size.width * .7, size.height * .08, size.width * .9, size.height * .02, size.width, size.height * .05)
      ..lineTo(size.width, size.height * .55)
      ..cubicTo(size.width, size.height * .78, size.width * .7, size.height * .94, size.width / 2, size.height)
      ..cubicTo(size.width * .3, size.height * .94, 0, size.height * .78, 0, size.height * .55)
      ..lineTo(0, size.height * .05)
      ..cubicTo(size.width * .1, size.height * .02, size.width * .3, size.height * .08, size.width / 2, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ShieldClipper oldClipper) => false;
}
