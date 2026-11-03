import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

Future<void> showNotesDialog(Drill drill) => Get.dialog<void>(
  NotesDialog(drill: drill),
  barrierColor: const Color(0xB3000000),
);

/// "Notes For <drill>": existing notes (edit / delete) + a field to add one.
/// Everything goes through the notes API.
class NotesDialog extends StatefulWidget {
  const NotesDialog({super.key, required this.drill});

  final Drill drill;

  @override
  State<NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<NotesDialog> {
  final TextEditingController _text = TextEditingController();
  final SkillsRepository _repo = Get.find<SkillsRepository>();

  List<SkillNote> _notes = const <SkillNote>[];
  bool _loading = true;
  bool _busy = false;
  int? _editingId;

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  /// true when the call worked. "Subscription required" closes the dialog
  /// and opens the Subscription page; other failures show a toast.
  bool _ok(ApiResponse<dynamic> res) {
    if (res.isSubscriptionRequired) {
      Get.back<void>();
      Get.toNamed<void>(AppRoutes.subscription);
      return false;
    }
    if (!res.success) {
      AppToast.error(res.message);
      return false;
    }
    return true;
  }

  Future<void> _refresh() async {
    final res = await _repo.fetchNotes(widget.drill.id);
    if (!mounted) return;
    setState(() {
      if (_ok(res)) _notes = res.data ?? const <SkillNote>[];
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final value = _text.text.trim();
    if (value.isEmpty || _busy) return;
    setState(() => _busy = true);

    final editing = _editingId;
    final res = editing == null
        ? await _repo.addNote(widget.drill.id, value)
        : await _repo.updateNote(editing, value);
    if (!mounted) return;

    if (_ok(res)) {
      // Saved: show the server's message and close the popup.
      AppToast.success(res.message);
      Get.back<void>();
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

  void _edit(SkillNote note) {
    setState(() {
      _editingId = note.id;
      _text.text = note.text;
      _text.selection = TextSelection.collapsed(offset: note.text.length);
    });
  }

  Future<void> _delete(SkillNote note) async {
    if (_busy) return;
    setState(() => _busy = true);

    final res = await _repo.deleteNote(note.id);
    if (!mounted) return;

    if (_ok(res)) {
      AppToast.success(res.message);
      Get.back<void>();
      return;
    }
    if (mounted) setState(() => _busy = false);
  }

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
      insetPadding: EdgeInsets.symmetric(horizontal: 19 * s, vertical: 24 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * s)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20 * s, 24 * s, 20 * s, 20 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                'Notes For ${widget.drill.title}',
                style: AppTextStyles.dialogTitle.scaled(s),
              ),
            ),
            SizedBox(height: 16 * s),
            if (_loading)
              Padding(
                padding: EdgeInsets.only(bottom: 14 * s),
                child: Center(
                  child: SizedBox(
                    width: 20 * s,
                    height: 20 * s,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            for (final note in _notes)
              Padding(
                padding: EdgeInsets.only(bottom: 14 * s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(note.text, style: AppTextStyles.dialogBody.scaled(s)),
                          SizedBox(height: 4 * s),
                          Text(
                            _date(note.createdAt),
                            style: AppTextStyles.dialogBody
                                .scaled(s)
                                .copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    _SquareButton(
                      icon: Icons.edit_outlined,
                      color: AppColors.selectGreen,
                      label: 'Edit note',
                      scale: s,
                      onTap: () => _edit(note),
                    ),
                    SizedBox(width: 8 * s),
                    _SquareButton(
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      label: 'Delete note',
                      scale: s,
                      onTap: () => _delete(note),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: _text,
              minLines: 4,
              maxLines: 4,
              style: AppTextStyles.dialogBody
                  .scaled(s)
                  .copyWith(color: AppColors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Enter Note here ...',
                hintStyle: AppTextStyles.dialogBody
                    .scaled(s)
                    .copyWith(color: AppColors.hint),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: EdgeInsets.all(14 * s),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                  borderSide: const BorderSide(color: AppColors.selectGreen),
                ),
              ),
            ),
            SizedBox(height: 20 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _OutlinedAction(
                  label: 'Cancel',
                  color: AppColors.selectGreen,
                  scale: s,
                  onTap: () => Get.back<void>(),
                ),
                SizedBox(width: 10 * s),
                _OutlinedAction(
                  label: _busy
                      ? '...'
                      : (_editingId == null ? 'Add' : 'Update'),
                  color: AppColors.white,
                  scale: s,
                  onTap: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 38 * scale;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Icon(icon, size: 20 * scale, color: color),
        ),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({
    required this.label,
    required this.color,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color color;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 9 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: AppTextStyles.dialogBody
              .scaled(scale)
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
