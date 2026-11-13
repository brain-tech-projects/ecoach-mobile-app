import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

const Color _barrier = Color(0xB3000000);

/// Entry points for every coach popup. Each returns true when something changed.
abstract final class CoachDialogs {
  static CoachPortalRepository get _repo {
    ensureCoachPortalRepository();
    return Get.find<CoachPortalRepository>();
  }

  static Future<bool> confirm(String title, String message) async =>
      (await Get.dialog<bool>(CompleteDialog(title: title, message: message), barrierColor: _barrier)) == true;

  static Future<bool> invitePlayer() async =>
      (await Get.dialog<bool>(
        _InvitePlayerDialog(onSend: (email) => coachRun(() => _repo.invitePlayer(email), success: 'Invitation sent successfully')),
        barrierColor: _barrier,
      )) ==
      true;

  /// "New group" and "Add Players" on a team (same popup, with group name).
  static Future<bool> assignToTeam(CoachTeam team) async =>
      (await Get.dialog<bool>(
        _AssignDialog(
          title: 'Assign Players To Team',
          body: 'Select one or more players from your team to include in the Group.',
          askName: true,
          onSubmit: (name, ids) => coachRun(() => _repo.createGroup(team.id, name, ids), success: 'Group created successfully'),
        ),
        barrierColor: _barrier,
      )) ==
      true;

  static Future<bool> assignToProgram(TrainingProgram program) async =>
      (await Get.dialog<bool>(
        _AssignDialog(
          title: 'Add Players To Program',
          body: 'Select one or more players to receive this training.',
          askName: false,
          onSubmit: (_, ids) => coachRun(() => _repo.addPlayersToProgram(program.id, ids), success: 'Players added successfully'),
        ),
        barrierColor: _barrier,
      )) ==
      true;

  static Future<bool> notifyPlayers({CoachPlayer? preselected}) async =>
      (await Get.dialog<bool>(
        _NotifyDialog(
          preselected: preselected,
          onSend: (ids, title, text) => coachRun(
            () => _repo.notifyPlayers(playerIds: ids, title: title, description: text),
            success: 'Notification sent successfully',
          ),
        ),
        barrierColor: _barrier,
      )) ==
      true;

  static Future<bool> renameProgram(TrainingProgram program) async =>
      (await Get.dialog<bool>(
        _RenameDialog(
          initial: program.title,
          onSave: (title) => coachRun(() => _repo.renameProgram(program.id, title), success: 'Program updated successfully'),
        ),
        barrierColor: _barrier,
      )) ==
      true;
}

// ---------------------------------------------------------------------------
class _Shell extends StatelessWidget {
  const _Shell({required this.title, required this.children, required this.actions, this.body, this.extraGap = 0});
  final String title;
  final String? body;
  final List<Widget> children;
  final List<Widget> actions;
  final double extraGap;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Dialog(
      backgroundColor: AppColors.dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 19 * s, vertical: 24 * s),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26 * s)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(26 * s, 26 * s, 26 * s, 24 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: Text(title, style: AppTextStyles.dialogTitle.scaled(s).copyWith(fontSize: 20 * s))),
            if (body != null) ...<Widget>[SizedBox(height: 14 * s), Text(body!, style: AppTextStyles.dialogBody.scaled(s))],
            SizedBox(height: 18 * s),
            ...children,
            SizedBox(height: 22 * s + extraGap),
            CoachButtonRow(children: actions),
          ],
        ),
      ),
    );
  }
}

class _InvitePlayerDialog extends StatefulWidget {
  const _InvitePlayerDialog({required this.onSend});
  final Future<bool> Function(String email) onSend;

  @override
  State<_InvitePlayerDialog> createState() => _InvitePlayerDialogState();
}

class _InvitePlayerDialogState extends State<_InvitePlayerDialog> {
  final TextEditingController _email = TextEditingController();
  bool _busy = false;

  Future<void> _send() async {
    final value = _email.text.trim();
    if (!Validators.isEmail(value)) {
      AppToast.error('Please enter a valid email address.');
      return;
    }
    setState(() => _busy = true);
    final ok = await widget.onSend(value);
    if (!mounted) return;
    if (ok) {
      Get.back<bool>(result: true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Invite a Player',
    body: 'Enter the player\'s email address. If they\'re already registered, they\'ll receive an invitation to join your team. If not, they\'ll get an email with a link to sign up.',
    children: <Widget>[CoachTextField(controller: _email, hint: 'player@example.com', dialog: true, keyboardType: TextInputType.emailAddress, autofocus: true)],
    actions: <Widget>[
      CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, onTap: () => Get.back<bool>(result: false)),
      CoachButton(label: 'Send Invitation', kind: CoachButtonKind.white, loading: _busy, onTap: _send),
    ],
  );
}

class _AssignDialog extends StatefulWidget {
  const _AssignDialog({required this.title, required this.body, required this.askName, required this.onSubmit});
  final String title;
  final String body;
  final bool askName;
  final Future<bool> Function(String name, List<int> ids) onSubmit;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  final TextEditingController _name = TextEditingController();
  final Set<int> _selected = <int>{};
  List<CoachPlayer>? _players;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    ensureCoachPortalRepository();
    try {
      final list = await Get.find<CoachPortalRepository>().fetchPlayers(force: force);
      if (mounted) setState(() { _players = list; _failed = false; });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _invite() async {
    if (await CoachDialogs.invitePlayer()) {
      setState(() => _players = null);
      await _load(force: true);
    }
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (widget.askName && name.isEmpty) {
      AppToast.error('Please enter a group name.');
      return;
    }
    if (_selected.isEmpty) {
      AppToast.error('Please select at least one player.');
      return;
    }
    setState(() => _busy = true);
    final ok = await widget.onSubmit(name, _selected.toList());
    if (!mounted) return;
    if (ok) {
      Get.back<bool>(result: true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final players = _players;
    return _Shell(
      title: widget.title,
      body: widget.body,
      children: <Widget>[
        if (widget.askName) ...<Widget>[CoachTextField(controller: _name, hint: 'Enter Group Name', light: true), SizedBox(height: 18 * s)],
        if (_failed)
          CoachEmpty(text: 'Could not load your players.', onRetry: _load)
        else if (players == null)
          Padding(padding: EdgeInsets.symmetric(vertical: 20 * s), child: const Center(child: CircularProgressIndicator(color: AppColors.accent)))
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 240 * s),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: players.length,
              separatorBuilder: (_, _) => SizedBox(height: 8 * s),
              itemBuilder: (_, i) {
                final p = players[i];
                return CoachPlayerTile(
                  dialog: true,
                  player: p,
                  selected: _selected.contains(p.id),
                  onTap: () => setState(() => _selected.contains(p.id) ? _selected.remove(p.id) : _selected.add(p.id)),
                );
              },
            ),
          ),
        SizedBox(height: 14 * s),
        GestureDetector(
          onTap: _invite,
          child: DashedBox(
            color: AppColors.selectGreen,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.selectGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12 * s)),
              child: Text.rich(
                TextSpan(children: <InlineSpan>[
                  TextSpan(text: 'Player not found?  ', style: AppTextStyles.dialogBody.scaled(s).copyWith(color: AppColors.accent)),
                  TextSpan(text: 'Invite Player', style: AppTextStyles.dialogBody.scaled(s).copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ),
      ],
      extraGap: 44 * s,
      actions: <Widget>[
        CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, onTap: () => Get.back<bool>(result: false)),
        CoachButton(label: 'Send', loading: _busy, onTap: _submit),
      ],
    );
  }
}

class _NotifyDialog extends StatefulWidget {
  const _NotifyDialog({required this.onSend, this.preselected});
  final CoachPlayer? preselected;
  final Future<bool> Function(List<int> ids, String title, String text) onSend;

  @override
  State<_NotifyDialog> createState() => _NotifyDialogState();
}

class _NotifyDialogState extends State<_NotifyDialog> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _text = TextEditingController();
  List<CoachPlayer> _players = const <CoachPlayer>[];
  bool _loading = true;
  bool _busy = false;
  int? _playerId;

  @override
  void initState() {
    super.initState();
    if (widget.preselected != null) {
      _playerId = widget.preselected!.id;
    }
    _load();
  }

  Future<void> _load() async {
    ensureCoachPortalRepository();
    try {
      final list = await Get.find<CoachPortalRepository>().fetchPlayers();
      if (mounted) setState(() => _players = list);
    } catch (_) {
      // picker simply stays empty; the user can retry by reopening.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    if (_playerId == null) {
      AppToast.error('Please select a player.');
      return;
    }
    if (_title.text.trim().isEmpty) {
      AppToast.error('The Notification Title field is required.');
      return;
    }
    if (_text.text.trim().isEmpty) {
      AppToast.error('The Notification Description field is required.');
      return;
    }
    setState(() => _busy = true);
    final ok = await widget.onSend(<int>[_playerId!], _title.text.trim(), _text.text.trim());
    if (!mounted) return;
    if (ok) {
      Get.back<bool>(result: true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return _Shell(
      title: 'Send Notification To Players',
      children: <Widget>[
        CoachDropdown<int>(
          hint: 'Select Player',
          dialog: true,
          loading: _loading,
          value: _playerId,
          items: <CoachPickItem<int>>[for (final p in _players) CoachPickItem<int>(value: p.id, label: p.name)],
          onChanged: (id) => setState(() => _playerId = id),
        ),
        SizedBox(height: 16 * s),
        CoachTextField(controller: _title, hint: 'Notification Title', dialog: true),
        SizedBox(height: 16 * s),
        CoachTextField(controller: _text, hint: 'Notification Description', dialog: true, maxLines: 3),
      ],
      actions: <Widget>[
        CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, onTap: () => Get.back<bool>(result: false)),
        CoachButton(label: 'Send', loading: _busy, onTap: _send),
      ],
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial, required this.onSave});
  final String initial;
  final Future<bool> Function(String title) onSave;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);
  bool _busy = false;

  Future<void> _save() async {
    final v = _c.text.trim();
    if (v.isEmpty) {
      AppToast.error('The Program Name field is required.');
      return;
    }
    setState(() => _busy = true);
    final ok = await widget.onSave(v);
    if (!mounted) return;
    if (ok) {
      Get.back<bool>(result: true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Edit Program',
    children: <Widget>[CoachTextField(controller: _c, hint: 'Program Name', dialog: true, autofocus: true)],
    actions: <Widget>[
      CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, onTap: () => Get.back<bool>(result: false)),
      CoachButton(label: 'Save', loading: _busy, onTap: _save),
    ],
  );
}
