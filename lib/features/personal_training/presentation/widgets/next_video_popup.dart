import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// "Next video will play in 3" with a Cancel button.
class NextVideoPopup extends StatelessWidget {
  const NextVideoPopup({
    super.key,
    required this.seconds,
    required this.onCancel,
    required this.scale,
  });

  final int seconds;
  final VoidCallback onCancel;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      liveRegion: true,
      label: 'Next video will play in $seconds seconds',
      child: Container(
        constraints: BoxConstraints(minWidth: 240 * s),
        padding: EdgeInsets.fromLTRB(24 * s, 18 * s, 24 * s, 18 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14 * s),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Next video will play in',
              textAlign: TextAlign.center,
              style: AppTextStyles.dialogTitle.scaled(s * 0.9),
            ),
            SizedBox(height: 4 * s),
            Text(
              '$seconds',
              style: AppTextStyles.dialogTitle
                  .scaled(s * 1.1)
                  .copyWith(color: const Color(0xFF5BB8F5)),
            ),
            SizedBox(height: 12 * s),
            Material(
              color: const Color(0xFFD9453B),
              borderRadius: BorderRadius.circular(8 * s),
              child: InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(8 * s),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 26 * s,
                    vertical: 10 * s,
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.dialogButton.scaled(s * 0.95),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
