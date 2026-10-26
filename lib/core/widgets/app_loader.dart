import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
}
