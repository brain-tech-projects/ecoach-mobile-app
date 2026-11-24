import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// "Delete Account": the user must type CONFIRM (case sensitive).
///
/// [onDelete] returns true when the account was deleted. The caller then
/// navigates away (which also closes this dialog), so it is not popped here.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.onDelete});

  final Future<bool> Function() onDelete;

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  static const String _word = 'CONFIRM';
  static const Color _red = Color(0xFFE84855);
  static const Color _pink = Color(0xFFF9C1BC);

  final TextEditingController _input = TextEditingController();
  bool _busy = false;

  bool get _ready => _input.text == _word && !_busy;

  Future<void> _delete() async {
    if (!_ready) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    final ok = await widget.onDelete();
    if (!mounted) return;
    if (!ok) setState(() => _busy = false);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;

    TextStyle text(double size, {FontWeight w = FontWeight.w400, Color c = AppColors.white, double? h}) =>
        TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: size * s, fontWeight: w, color: c, height: h);

    return PopScope(
      canPop: !_busy,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 24 * s),
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 40 * s),
                padding: EdgeInsets.fromLTRB(26 * s, 66 * s, 26 * s, 26 * s),
                decoration: BoxDecoration(
                  color: AppColors.dialogBg,
                  borderRadius: BorderRadius.circular(26 * s),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text('Delete Account', textAlign: TextAlign.center, style: text(24, w: FontWeight.w600)),
                    ),
                    SizedBox(height: 18 * s),
                    Text(
                      "If you decide to use this app again, you'll need to create a new account.",
                      textAlign: TextAlign.center,
                      style: text(15.5, h: 1.45),
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      'To finish deleting your account, please type "$_word" below to proceed',
                      textAlign: TextAlign.center,
                      style: text(15.5, h: 1.45),
                    ),
                    SizedBox(height: 18 * s),
                    TextField(
                      controller: _input,
                      enabled: !_busy,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _delete(),
                      style: text(17),
                      decoration: InputDecoration(
                        hintText: 'Type $_word',
                        hintStyle: text(17, c: const Color(0xFF7F95A0)),
                        filled: true,
                        fillColor: const Color(0xFF245161),
                        contentPadding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 16 * s),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14 * s),
                          borderSide: const BorderSide(color: Color(0xFF6C7F88)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14 * s),
                          borderSide: const BorderSide(color: Color(0xFF6C7F88)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14 * s),
                          borderSide: const BorderSide(color: _pink),
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * s),
                    Text('This field is case sensitive', textAlign: TextAlign.center, style: text(15.5)),
                    SizedBox(height: 30 * s),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _Btn(
                            label: 'cancel',
                            filled: false,
                            color: _red,
                            enabled: !_busy,
                            scale: s,
                            onTap: () => Get.back<void>(),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Expanded(
                          flex: 2,
                          child: _Btn(
                            label: _busy ? 'Deleting...' : 'Delete Account',
                            filled: true,
                            color: _red,
                            enabled: _ready,
                            scale: s,
                            onTap: _delete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 82 * s,
                height: 82 * s,
                decoration: BoxDecoration(
                  color: _pink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3 * s),
                ),
                child: Icon(Icons.warning_amber_rounded, size: 44 * s, color: _red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.filled,
    required this.color,
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final Color color;
  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled || !filled ? 1 : 0.6,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Container(
            height: 54 * s,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: filled ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(10 * s),
              border: filled ? null : Border.all(color: color, width: 2 * s),
            ),
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17 * s,
                fontWeight: FontWeight.w500,
                color: filled ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
