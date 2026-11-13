import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------
enum CoachButtonKind { primary, outline, white }

class CoachButton extends StatelessWidget {
  const CoachButton({super.key, required this.label, required this.onTap, this.kind = CoachButtonKind.primary, this.enabled = true, this.loading = false, this.minWidth});

  final String label;
  final VoidCallback? onTap;
  final CoachButtonKind kind;
  final bool enabled;
  final bool loading;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final active = enabled && !loading;
    Color fill = Colors.transparent;
    Color border;
    Color text;
    switch (kind) {
      case CoachButtonKind.primary:
        fill = active ? AppColors.accent : Colors.transparent;
        border = active ? AppColors.accent : AppColors.unselectedBorder;
        text = active ? AppColors.black : AppColors.unselectedBorder;
      case CoachButtonKind.outline:
        border = active ? AppColors.accent : AppColors.unselectedBorder;
        text = active ? AppColors.accent : AppColors.unselectedBorder;
      case CoachButtonKind.white:
        border = AppColors.white;
        text = AppColors.white;
    }
    return Semantics(
      button: true,
      enabled: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active ? onTap : null,
        child: Container(
          constraints: BoxConstraints(minWidth: (minWidth ?? 104) * s, minHeight: 44 * s),
          padding: EdgeInsets.symmetric(horizontal: 18 * s),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12 * s), border: Border.all(color: border, width: 1.3)),
          child: loading
              ? SizedBox(width: 18 * s, height: 18 * s, child: CircularProgressIndicator(strokeWidth: 2, color: text))
              : Text(label, style: AppTextStyles.buttonLabelSmall.scaled(s).copyWith(color: text, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class CoachButtonRow extends StatelessWidget {
  const CoachButtonRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[for (var i = 0; i < children.length; i++) ...<Widget>[if (i > 0) SizedBox(width: 8 * s), children[i]]],
    );
  }
}

/// Round green "+" button (bottom-right of list pages).
class CoachFab extends StatelessWidget {
  const CoachFab({super.key, required this.onTap, this.label = 'Add'});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Padding(
      padding: EdgeInsets.only(right: 5.3 * s, bottom: 6.7 * s),
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 55 * s,
            height: 55 * s,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.accent, Color(0xFF2FA52A)]),
              boxShadow: <BoxShadow>[BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Icon(Icons.add, size: 30 * s, color: AppColors.black),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
class CoachTextField extends StatelessWidget {
  const CoachTextField({super.key, required this.controller, required this.hint, this.maxLines = 1, this.light = false, this.dialog = false, this.keyboardType, this.autofocus = false, this.errorText, this.onChanged});

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  /// White field with dark text (group name in the assign dialog).
  final bool light;

  /// Translucent field used inside dialogs.
  final bool dialog;
  final TextInputType? keyboardType;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final fill = light ? AppColors.white : (dialog ? Colors.white.withValues(alpha: 0.08) : AppColors.fieldFill);
    final textColor = light ? AppColors.black : AppColors.white;
    OutlineInputBorder border(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular((maxLines > 1 ? 14 : 12) * s), borderSide: BorderSide(color: c));

    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      keyboardType: keyboardType,
      autofocus: autofocus,
      onChanged: onChanged,
      textCapitalization: keyboardType == TextInputType.emailAddress ? TextCapitalization.none : TextCapitalization.sentences,
      style: AppTextStyles.fieldText.scaled(s).copyWith(color: textColor),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: AppTextStyles.fieldHint.scaled(s).copyWith(color: light ? AppColors.hint : null),
        filled: true,
        fillColor: fill,
        contentPadding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 16 * s),
        enabledBorder: border(dialog ? AppColors.cardBorder : AppColors.fieldBorder),
        focusedBorder: border(AppColors.selectGreen),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error),
      ),
    );
  }
}

class CoachSearchField extends StatelessWidget {
  const CoachSearchField({super.key, required this.onChanged, this.hint = 'Search'});
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.fieldText.scaled(s),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.fieldHint.scaled(s).copyWith(color: AppColors.white.withValues(alpha: 0.85)),
        filled: true,
        fillColor: const Color(0xFF4A5A60),
        suffixIcon: Icon(Icons.search, color: AppColors.white, size: 26 * s),
        contentPadding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 17 * s),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * s), borderSide: const BorderSide(color: AppColors.fieldBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * s), borderSide: const BorderSide(color: AppColors.selectGreen)),
      ),
    );
  }
}

class CoachPickItem<T> {
  const CoachPickItem({required this.value, required this.label, this.imageUrl});
  final T value;
  final String label;
  final String? imageUrl;
}

/// Green-bordered "dropdown": opens a bottom-sheet list.
class CoachSelectField extends StatelessWidget {
  const CoachSelectField({super.key, required this.hint, this.value, this.imageUrl, this.onTap, this.loading = false, this.dialog = false});

  final String hint;
  final String? value;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool loading;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Semantics(
      button: true,
      label: value ?? hint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: loading ? null : onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 58 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: dialog ? const Color(0xFF25505F) : AppColors.popupBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: AppColors.selectGreen, width: 1.3),
          ),
          child: Row(
            children: <Widget>[
              if (imageUrl != null && imageUrl!.isNotEmpty) ...<Widget>[
                CircleAvatar(radius: 20 * s, backgroundImage: NetworkImage(imageUrl!), backgroundColor: AppColors.avatarBg),
                SizedBox(width: 12 * s),
              ],
              Expanded(
                child: Text(value ?? hint, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: (value == null ? 16 : 16) * s, fontWeight: value == null ? FontWeight.w400 : FontWeight.w600)),
              ),
              if (loading)
                SizedBox(width: 18 * s, height: 18 * s, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
              else
                Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: 26 * s),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showCoachPicker<T>({required String title, required List<CoachPickItem<T>> items}) {
  return Get.bottomSheet<T>(
    _PickerSheet<T>(title: title, items: items),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({required this.title, required this.items});
  final String title;
  final List<CoachPickItem<T>> items;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final maxH = MediaQuery.sizeOf(context).height * 0.65;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 12 * s),
        decoration: BoxDecoration(color: AppColors.popupBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: AppTextStyles.dialogTitle.scaled(s)),
            SizedBox(height: 8 * s),
            if (items.isEmpty)
              Padding(padding: EdgeInsets.symmetric(vertical: 24 * s), child: Center(child: Text('Nothing to select yet.', style: AppTextStyles.dialogBody.scaled(s))))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.popupDivider),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 4 * s),
                      leading: (item.imageUrl == null || item.imageUrl!.isEmpty) ? null : CircleAvatar(backgroundImage: NetworkImage(item.imageUrl!), backgroundColor: AppColors.avatarBg),
                      title: Text(item.label, style: AppTextStyles.dialogBody.scaled(s)),
                      onTap: () => Get.back<T>(result: item.value),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cards / tiles
// ---------------------------------------------------------------------------
class CoachCard extends StatelessWidget {
  const CoachCard({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11 * s), side: const BorderSide(color: AppColors.cardBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding ?? EdgeInsets.all(12 * s), child: child)),
    );
  }
}

class CoachPlayerAvatar extends StatelessWidget {
  const CoachPlayerAvatar({super.key, required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.person, size: size * 0.62, color: AppColors.avatarFg);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: AppColors.avatarBg, shape: BoxShape.circle),
      child: (url == null || url!.isEmpty) ? fallback : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
    );
  }
}

String? coachFlag(String? code) => (code == null || code.length != 2) ? null : Country(code: code, name: '').flag;

class CoachPlayerTile extends StatelessWidget {
  const CoachPlayerTile({super.key, required this.player, this.onTap, this.selected = false, this.dialog = false});
  final CoachPlayer player;
  final VoidCallback? onTap;
  final bool selected;

  /// Teal tile used inside dialogs.
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final flag = coachFlag(player.countryCode);
    return Material(
      color: (selected || dialog) ? const Color(0xFF25505F) : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11 * s),
        side: BorderSide(color: selected ? AppColors.selectGreen : AppColors.cardBorder, width: selected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(11 * s),
          child: Row(
            children: <Widget>[
              CoachPlayerAvatar(url: player.photoUrl, size: 54 * s),
              SizedBox(width: 14 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w600)),
                    if (player.subtitle.isNotEmpty) Text(player.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programDesc.scaled(s)),
                  ],
                ),
              ),
              if (flag != null) Text(flag, style: TextStyle(fontSize: 38 * s)),
            ],
          ),
        ),
      ),
    );
  }
}

class CoachPill extends StatelessWidget {
  const CoachPill({super.key, required this.label, this.icon, this.accent = false, this.onTap, this.badge, this.onRemove});
  final String label;
  final IconData? icon;
  final bool accent;
  final VoidCallback? onTap;
  final int? badge;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final color = accent ? AppColors.accent : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
        decoration: BoxDecoration(
          color: accent ? AppColors.selectGreen.withValues(alpha: 0.22) : const Color(0xFF4A5C62),
          borderRadius: BorderRadius.circular(30 * s),
          border: accent ? Border.all(color: AppColors.selectGreen.withValues(alpha: 0.6)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[Icon(icon, size: 19 * s, color: color), SizedBox(width: 6 * s)],
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.programTitle.scaled(s).copyWith(color: color, fontWeight: FontWeight.w600))),
            if (badge != null) ...<Widget>[
              SizedBox(width: 8 * s),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
                decoration: const BoxDecoration(color: Color(0xFF6B7B80), shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Text('$badge', style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 13 * s)),
              ),
            ],
            if (onRemove != null) ...<Widget>[
              SizedBox(width: 8 * s),
              GestureDetector(
                onTap: onRemove,
                child: Container(width: 22 * s, height: 22 * s, decoration: const BoxDecoration(color: Color(0xFFE5575C), shape: BoxShape.circle), child: Icon(Icons.close, size: 14 * s, color: AppColors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CoachMenuEntry {
  const CoachMenuEntry(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// Three-dot menu: Add Players / Edit / Remove.
class CoachKebab extends StatelessWidget {
  const CoachKebab({super.key, required this.entries});
  final List<CoachMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: AppColors.popupDivider),
      child: PopupMenuButton<int>(
        tooltip: 'More',
        padding: EdgeInsets.zero,
        color: AppColors.popupBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * s), side: const BorderSide(color: AppColors.popupDivider)),
        icon: Icon(Icons.more_vert, color: AppColors.white, size: 24 * s),
        onSelected: (i) => entries[i].onTap(),
        itemBuilder: (_) => <PopupMenuEntry<int>>[
          for (var i = 0; i < entries.length; i++) ...<PopupMenuEntry<int>>[
            if (i > 0) const PopupMenuDivider(height: 1),
            PopupMenuItem<int>(
              value: i,
              height: 48 * s,
              child: Row(children: <Widget>[Icon(entries[i].icon, color: AppColors.white, size: 22 * s), SizedBox(width: 14 * s), Text(entries[i].label, style: AppTextStyles.popupItem.scaled(s).copyWith(color: AppColors.white))]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dashed rounded border around [child].
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.child, this.color = AppColors.unselectedBorder, this.radius = 12});
  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DashPainter(color, radius), child: child);
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.3;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color || old.radius != radius;
}

class CoachEmpty extends StatelessWidget {
  const CoachEmpty({super.key, required this.text, this.onRetry});
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40 * s, horizontal: 24 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text, textAlign: TextAlign.center, style: AppTextStyles.onboardingBody.scaled(s)),
          if (onRetry != null) TextButton(onPressed: onRetry, child: Text('Retry', style: AppTextStyles.action.scaled(s))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat tile + Notify card
// ---------------------------------------------------------------------------
class CoachStatTile extends StatelessWidget {
  const CoachStatTile({super.key, required this.icon, required this.value, required this.label, this.onTap});
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Material(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * s), side: const BorderSide(color: AppColors.cardBorder)),
      child: InkWell(
        onTap: onTap,
        child: CustomPaint(
          painter: _Circles(s),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 122.7 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(11 * s, 14 * s, 11 * s, 12 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(icon, size: 20 * s, color: AppColors.white),
                  SizedBox(height: 6 * s),
                  Text(value, style: AppTextStyles.statValue.scaled(s)),
                  SizedBox(height: 3 * s),
                  Text(label, style: AppTextStyles.statLabel.scaled(s)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green-bordered "Create Training" tile of the coach home.
class CoachCreateTile extends StatelessWidget {
  const CoachCreateTile({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Material(
      color: const Color(0xFF1D4A3A),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * s), side: const BorderSide(color: AppColors.accent, width: 1.5)),
      child: InkWell(
        onTap: onTap,
        child: CustomPaint(
          painter: _Circles(s),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 122.7 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(11 * s, 14 * s, 11 * s, 12 * s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 55 * s,
                    height: 55 * s,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16 * s),
                      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[AppColors.accent, Color(0xFF2FA52A)]),
                    ),
                    child: Icon(Icons.add, size: 32 * s, color: AppColors.black),
                  ),
                  SizedBox(height: 10 * s),
                  Text('Create Training', style: AppTextStyles.statLabel.scaled(s)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Circles extends CustomPainter {
  const _Circles(this.scale);
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.cardCircle.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(142.7 * scale, 70 * scale), 36.7 * scale, paint);
    canvas.drawCircle(Offset(149.3 * scale, 20 * scale), 21.7 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _Circles old) => old.scale != scale;
}

class CoachNotifyCard extends StatelessWidget {
  const CoachNotifyCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(26 * s, 26 * s, 26 * s, 26 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22 * s),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Color(0xFF17513A), Color(0xFF1E3338)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Notify Your Players', style: AppTextStyles.heroTitle.scaled(s).copyWith(fontSize: 20 * s)),
          SizedBox(height: 8 * s),
          Text('Send important messages to help your team stay focused and aligned.', style: AppTextStyles.heroSubtitle.scaled(s).copyWith(fontSize: 15 * s, fontWeight: FontWeight.w400)),
          SizedBox(height: 18 * s),
          Material(
            color: AppColors.accent,
            shape: const StadiumBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 13 * s),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform.rotate(angle: -0.5, child: Icon(Icons.send_outlined, size: 20 * s, color: AppColors.black)),
                    SizedBox(width: 12 * s),
                    Text('Send Notification to Players', style: AppTextStyles.heroButton.scaled(s).copyWith(fontSize: 15 * s, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Network URL or local file (picked image).
Widget coachImage(String src, Widget fallback) => src.startsWith('http')
    ? Image.network(src, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback)
    : Image.file(File(src), fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);

ImageProvider coachImageProvider(String src) => src.startsWith('http') ? NetworkImage(src) as ImageProvider : AssetImage(src);

/// Inline dropdown (list opens right under the field, like the web app).
/// [searchHint] makes the field searchable ("Search & Select ...").
class CoachDropdown<T> extends StatefulWidget {
  const CoachDropdown({super.key, required this.hint, required this.items, required this.onChanged, this.value, this.searchHint, this.dialog = false, this.loading = false});

  final String hint;
  final String? searchHint;
  final List<CoachPickItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final bool dialog;
  final bool loading;

  @override
  State<CoachDropdown<T>> createState() => _CoachDropdownState<T>();
}

class _CoachDropdownState<T> extends State<CoachDropdown<T>> {
  final TextEditingController _q = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _open = false;

  bool get _searchable => widget.searchHint != null;

  CoachPickItem<T>? get _selected {
    for (final i in widget.items) {
      if (i.value == widget.value) return i;
    }
    return null;
  }

  List<CoachPickItem<T>> get _shown {
    final q = _q.text.trim().toLowerCase();
    return q.isEmpty ? widget.items : widget.items.where((e) => e.label.toLowerCase().contains(q)).toList();
  }

  void _toggle() {
    if (widget.loading || widget.items.isEmpty && !_open) return;
    setState(() => _open = !_open);
    if (_open && _searchable) {
      _focus.requestFocus();
    } else {
      _focus.unfocus();
    }
  }

  void _pick(CoachPickItem<T> item) {
    widget.onChanged(item.value);
    _q.clear();
    _focus.unfocus();
    setState(() => _open = false);
  }

  @override
  void dispose() {
    _q.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final sel = _selected;
    final hasImage = widget.items.any((e) => e.imageUrl != null);
    final border = _open && _searchable ? const Color(0xFF3FA7C8) : AppColors.selectGreen;
    final valueStyle = AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w600);
    final hintStyle = AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w400);

    final field = Semantics(
      button: true,
      label: sel?.label ?? widget.hint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          constraints: BoxConstraints(minHeight: (sel?.imageUrl != null ? 72 : 58) * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: widget.dialog ? const Color(0xFF25505F) : AppColors.popupBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: border, width: 1.3),
          ),
          child: Row(
            children: <Widget>[
              if (sel?.imageUrl != null) ...<Widget>[
                CircleAvatar(radius: 20 * s, backgroundImage: coachImageProvider(sel!.imageUrl!), backgroundColor: AppColors.avatarBg),
                SizedBox(width: 12 * s),
              ],
              Expanded(
                child: _searchable && _open
                    ? TextField(
                        controller: _q,
                        focusNode: _focus,
                        onChanged: (_) => setState(() {}),
                        cursorColor: AppColors.accent,
                        style: valueStyle,
                        decoration: InputDecoration(isDense: true, border: InputBorder.none, hintText: sel?.label ?? widget.searchHint, hintStyle: sel != null ? valueStyle : hintStyle.copyWith(color: AppColors.white.withValues(alpha: 0.7))),
                      )
                    : Text(sel?.label ?? (_searchable ? widget.searchHint! : widget.hint), maxLines: 2, overflow: TextOverflow.ellipsis, style: sel != null ? valueStyle : hintStyle),
              ),
              if (widget.loading)
                SizedBox(width: 18 * s, height: 18 * s, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
              else
                Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: 26 * s),
            ],
          ),
        ),
      ),
    );

    final shown = _shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        field,
        if (_open)
          Container(
            margin: EdgeInsets.only(top: 6 * s),
            constraints: BoxConstraints(maxHeight: 290 * s),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: const Color(0xFF071B1F), borderRadius: BorderRadius.circular(8 * s)),
            child: shown.isEmpty
                ? Padding(padding: EdgeInsets.all(16 * s), child: Text('No results', style: hintStyle))
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: shown.length,
                    itemBuilder: (_, i) {
                      final it = shown[i];
                      final highlighted = widget.value == null ? shown[i] == shown.first : it.value == widget.value;
                      return InkWell(
                        onTap: () => _pick(it),
                        child: Container(
                          constraints: BoxConstraints(minHeight: 48 * s),
                          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                          color: highlighted ? const Color(0xFF1558B8) : Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              if (hasImage) ...<Widget>[
                                CircleAvatar(radius: 17 * s, backgroundColor: AppColors.avatarBg, backgroundImage: it.imageUrl == null ? null : coachImageProvider(it.imageUrl!)),
                                SizedBox(width: 14 * s),
                              ],
                              Expanded(child: Text(it.label, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 15 * s, fontWeight: hasImage ? FontWeight.w600 : FontWeight.w400, color: highlighted ? AppColors.white : AppColors.white.withValues(alpha: 0.85)))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
