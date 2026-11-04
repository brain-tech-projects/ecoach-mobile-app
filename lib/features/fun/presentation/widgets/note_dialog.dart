import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// Returns the trimmed note on Save (may be empty = delete), `null` on Cancel.
Future<String?> showNoteDialog({String initial = ''}) =>
    Get.dialog<String>(_NoteDialog(initial: initial));

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Dialog(
      backgroundColor: AppColors.dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 24 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * s)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Add Note', style: AppTextStyles.dialogTitle.scaled(s)),
            SizedBox(height: 12 * s),
            TextField(
              controller: _text,
              autofocus: true,
              maxLines: 4,
              minLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.fieldText.scaled(s),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: 'Write your note...',
                hintStyle: AppTextStyles.fieldHint.scaled(s),
                counterStyle: AppTextStyles.fieldHint.scaled(s),
                filled: true,
                fillColor: AppColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                  borderSide: const BorderSide(color: AppColors.fieldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                  borderSide: const BorderSide(color: AppColors.fieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8 * s),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            SizedBox(height: 12 * s),
            Row(
              children: <Widget>[
                Expanded(child: _Btn(label: 'Cancel', filled: false, scale: s, onTap: () => Get.back<void>())),
                SizedBox(width: 8 * s),
                Expanded(child: _Btn(label: 'Save', filled: true, scale: s, onTap: () => Get.back<String>(result: _text.text.trim()))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.filled, required this.scale, required this.onTap});

  final String label;
  final bool filled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 44 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(8 * scale),
        border: filled ? null : Border.all(color: AppColors.accent),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 16 * scale,
          fontWeight: FontWeight.w500,
          color: filled ? Colors.black : AppColors.accent,
        ),
      ),
    ),
  );
}
