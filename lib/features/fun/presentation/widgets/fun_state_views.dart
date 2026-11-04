import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

class FunLoader extends StatelessWidget {
  const FunLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accent),
  );
}

class FunErrorView extends StatelessWidget {
  const FunErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.scale,
  });

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.trainSubline.scaled(scale),
          ),
          SizedBox(height: 12 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: AppTextStyles.trainSubline
                  .copyWith(color: AppColors.accent)
                  .scaled(scale),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Asset path or network URL, with a neutral placeholder on failure.
class FunImage extends StatelessWidget {
  const FunImage(this.source, {super.key, this.fit = BoxFit.cover});

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext _, Object _, StackTrace? _) =>
        const ColoredBox(color: AppColors.cardCircle);
    return source.startsWith('http')
        ? Image.network(source, fit: fit, errorBuilder: fallback)
        : Image.asset(source, fit: fit, errorBuilder: fallback);
  }
}
