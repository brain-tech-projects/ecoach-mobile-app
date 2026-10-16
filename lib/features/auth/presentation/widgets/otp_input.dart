import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';

/// Six digit boxes backed by ONE hidden text field, so paste, SMS auto-fill
/// (`oneTimeCode`) and backspace all work natively.
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.length = 6,
    this.onChanged,
    this.scale = 1.0,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String>? onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: length,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                showCursor: false,
                enableInteractiveSelection: false,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final text = value.text;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: 8.67 * s),
                    Container(
                      width: 49.3 * s,
                      height: 49.3 * s,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.fieldFill,
                        border: Border.all(color: AppColors.accent),
                        borderRadius: BorderRadius.circular(10 * s),
                      ),
                      child: Text(
                        i < text.length ? text[i] : '',
                        style: AppTextStyles.otpDigit.scaled(s),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
