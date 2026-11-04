import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

const Color kProfileLabel = Color(0xFFA3B2B6);
const Color kProfileLine = Color(0xFF646869);
const Color kFieldFill = Color(0xFF28393F);
const Color kFieldBorder = Color(0xFF4A5C63);
const Color kChipFill = Color(0xFF75FB91);

TextStyle _label(double s) => TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 16 * s,
      height: 1.5,
      color: kProfileLabel,
    );

TextStyle _value(double s) => TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 18 * s,
      height: 1.5,
      color: AppColors.white,
    );

/// Label + underlined text field.
class UnderlineField extends StatelessWidget {
  const UnderlineField({
    super.key,
    required this.label,
    required this.controller,
    required this.scale,
    this.keyboardType,
    this.errorText,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final double scale;
  final TextInputType? keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    const line = UnderlineInputBorder(borderSide: BorderSide(color: kProfileLine, width: 1.2));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: _label(s)),
        SizedBox(height: 4 * s),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          cursorColor: AppColors.accent,
          style: _value(s),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 15 * s),
            enabledBorder: line,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorText: errorText,
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label + read-only underlined date with a calendar icon.
class DateUnderlineField extends StatelessWidget {
  const DateUnderlineField({
    super.key,
    required this.label,
    required this.text,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final String? text;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: '$label, ${text ?? 'not set'}',
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: _label(s)),
              SizedBox(height: 4 * s),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text ?? 'dd/mm/yyyy',
                      style: _value(s).copyWith(color: text == null ? AppColors.hint : AppColors.white),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 11.7 * s),
                    child: Icon(Icons.calendar_month_outlined, size: 22 * s, color: AppColors.textMuted),
                  ),
                ],
              ),
              SizedBox(height: 15 * s),
              const Divider(height: 1, thickness: 1.2, color: kProfileLine),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label + single-select box. Opens a sheet through [onTap] (which returns
/// when the sheet closes, so the box can show its focus border meanwhile).
class SelectBox extends StatefulWidget {
  const SelectBox({
    super.key,
    required this.label,
    required this.text,
    required this.onTap,
    required this.scale,
    this.placeholder = 'Select',
    this.leading,
  });

  final String label;
  final String? text;
  final String placeholder;
  final String? leading;
  final Future<void> Function() onTap;
  final double scale;

  @override
  State<SelectBox> createState() => _SelectBoxState();
}

class _SelectBoxState extends State<SelectBox> {
  bool _open = false;

  Future<void> _tap() async {
    setState(() => _open = true);
    await widget.onTap();
    if (mounted) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final has = widget.text != null && widget.text!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: _label(s)),
        SizedBox(height: 15.7 * s),
        Semantics(
          button: true,
          label: '${widget.label}, ${has ? widget.text : 'not selected'}',
          child: InkWell(
            borderRadius: BorderRadius.circular(17 * s),
            onTap: _tap,
            child: ExcludeSemantics(
              child: Container(
                constraints: BoxConstraints(minHeight: 51.3 * s),
                padding: EdgeInsets.fromLTRB(15 * s, 0, 19 * s, 0),
                decoration: BoxDecoration(
                  color: kFieldFill,
                  borderRadius: BorderRadius.circular(17 * s),
                  border: Border.all(
                    color: _open ? AppColors.accent : kFieldBorder,
                    width: _open ? 1.5 : 1.2,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    if (widget.leading != null) ...<Widget>[
                      Text(widget.leading!, style: TextStyle(fontSize: 18 * s)),
                      SizedBox(width: 10 * s),
                    ],
                    Expanded(
                      child: Text(
                        has ? widget.text! : widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _value(s).copyWith(color: has ? AppColors.white : AppColors.hint),
                      ),
                    ),
                    ThinChevron(up: false, color: AppColors.textMuted, scale: s),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label + multi-select box with green removable chips.
class MultiSelectBox extends StatelessWidget {
  const MultiSelectBox({
    super.key,
    required this.label,
    required this.values,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
    required this.scale,
  });

  final String label;
  final List<String> values;
  final VoidCallback onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: _label(s)),
        SizedBox(height: 15.7 * s),
        Container(
          constraints: BoxConstraints(minHeight: 51.3 * s),
          decoration: BoxDecoration(
            color: kFieldFill,
            borderRadius: BorderRadius.circular(17 * s),
            border: Border.all(color: kFieldBorder, width: 1.2),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  button: true,
                  label: '$label, ${values.isEmpty ? 'none selected' : values.join(', ')}',
                  child: InkWell(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(17 * s)),
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(14 * s, 3 * s, 4 * s, 3 * s),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: values.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 11 * s, horizontal: 1 * s),
                                child: Text('Select',
                                    style: _value(s).copyWith(color: AppColors.hint)),
                              )
                            : Wrap(
                                spacing: 4 * s,
                                runSpacing: 5.3 * s,
                                children: <Widget>[
                                  for (final v in values)
                                    _Chip(text: v, scale: s, onRemove: () => onRemove(v)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (values.isNotEmpty)
                IconButton(
                  tooltip: 'Clear $label',
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 36 * s, height: 36 * s),
                  icon: Icon(Icons.close, size: 20 * s, color: const Color(0xFFCCCCCC)),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8 * s, 12 * s, 19 * s, 12 * s),
                  child: ThinChevron(up: false, color: AppColors.textMuted, scale: s),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.scale, required this.onRemove});

  final String text;
  final double scale;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minHeight: 24.7 * s),
      padding: EdgeInsets.fromLTRB(6.3 * s, 0, 4 * s, 0),
      decoration: BoxDecoration(color: kChipFill, borderRadius: BorderRadius.circular(12.3 * s)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16 * s,
                height: 1.4,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(width: 6 * s),
          Semantics(
            button: true,
            label: 'Remove $text',
            child: InkWell(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.all(4 * s),
                child: Icon(Icons.close, size: 13 * s, color: AppColors.black, weight: 800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ sheets

class SheetOption {
  const SheetOption(this.value, this.label, {this.leading});
  final String value;
  final String label;
  final String? leading;
}

Widget _sheetFrame(BuildContext context, String title, Widget body, {Widget? footer}) {
  final s = Responsive.of(context).scale;
  return SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.popupBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
        ),
        padding: EdgeInsets.fromLTRB(20 * s, 20 * s, 20 * s, 12 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: AppTextStyles.dialogTitle.scaled(s)),
            SizedBox(height: 8 * s),
            Flexible(child: body),
            if (footer != null) footer,
          ],
        ),
      ),
    ),
  );
}

/// Picks one option; returns its value (null when dismissed).
Future<String?> showSingleSheet(
  BuildContext context, {
  required String title,
  required List<SheetOption> options,
  String? selected,
}) {
  final s = Responsive.of(context).scale;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _sheetFrame(
      ctx,
      title,
      ListView.builder(
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (_, i) {
          final o = options[i];
          final on = o.value == selected;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => Navigator.of(ctx).pop(o.value),
            leading: o.leading == null ? null : Text(o.leading!, style: TextStyle(fontSize: 22 * s)),
            title: Text(
              o.label,
              style: AppTextStyles.dialogBody.scaled(s).copyWith(
                    color: on ? AppColors.accent : AppColors.white,
                  ),
            ),
            trailing: on ? const Icon(Icons.check, color: AppColors.accent) : null,
          );
        },
      ),
    ),
  );
}

/// Toggles several options; returns the new list (null when dismissed).
Future<List<String>?> showMultiSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required List<String> selected,
}) {
  final s = Responsive.of(context).scale;
  final picked = List<String>.of(selected);
  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => _sheetFrame(
        ctx,
        title,
        ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (_, i) {
            final o = options[i];
            final on = picked.contains(o);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.trailing,
              value: on,
              activeColor: AppColors.accent,
              checkColor: AppColors.black,
              side: const BorderSide(color: AppColors.textMuted, width: 1.5),
              title: Text(o, style: AppTextStyles.dialogBody.scaled(s)),
              onChanged: (v) => setState(() => v == true ? picked.add(o) : picked.remove(o)),
            );
          },
        ),
        footer: Padding(
          padding: EdgeInsets.only(top: 8 * s),
          child: FilledButton(
            onPressed: () => Navigator.of(ctx).pop(picked),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.black,
              minimumSize: Size.fromHeight(46 * s),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * s)),
            ),
            child: Text('Done', style: AppTextStyles.buttonLabelSmall.scaled(s)),
          ),
        ),
      ),
    ),
  );
}
