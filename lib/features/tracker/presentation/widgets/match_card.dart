import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';

const Color _rowLine = Color(0xFF55656A);
const Color _popupFill = Color(0xFF0B3743);
const Color _chevronOpen = Color(0xFFF1D9A5);

enum _MatchAction { edit, delete }

/// Expandable match card: photo, opponent, date, all ratings.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.entry,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.scale,
  });

  final MatchEntry entry;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final e = entry;
    final rows = <(String, String)>[
      ('When did you play this match?', e.shortDate),
      ('Score:', e.score),
      ('Passing:', '${e.passing}'),
      ('Dribbling:', '${e.dribbling}'),
      ('Shooting:', '${e.shooting}'),
      ('Defending:', '${e.defending}'),
      ('Pace:', '${e.pace}'),
      ('Physicality:', '${e.physicality}'),
      ('Assists:', '${e.assists}'),
      ('Goals:', '${e.goals}'),
      ('Saves:', '${e.saves}'),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(11 * s, 10.7 * s, 11 * s, 10.7 * s),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(entry: e, expanded: expanded, onTap: onToggle, scale: s),
            if (expanded) ...<Widget>[
              SizedBox(height: 15.3 * s),
              const Divider(height: 1, thickness: 1, color: _rowLine),
              _OpponentRow(entry: e, scale: s, onEdit: onEdit, onDelete: onDelete),
              for (var i = 0; i < rows.length; i++) ...<Widget>[
                const Divider(height: 1, thickness: 1, color: _rowLine),
                _InfoRow(label: rows[i].$1, value: rows[i].$2, scale: s),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

TextStyle _label(double s) => TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 15 * s,
      height: 1.4,
      color: AppColors.descGrey,
    );

TextStyle _value(double s) => TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 17 * s,
      height: 1.4,
      color: AppColors.white,
    );

class _Header extends StatelessWidget {
  const _Header({required this.entry, required this.expanded, required this.onTap, required this.scale});

  final MatchEntry entry;
  final bool expanded;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      expanded: expanded,
      label: '${entry.opponent}, ${entry.longDate}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14 * s),
        onTap: onTap,
        child: ExcludeSemantics(
          child: SizedBox(
            height: 55 * s,
            child: Row(
              children: <Widget>[
                _Thumb(entry: entry, size: 55 * s, radius: 14 * s),
                SizedBox(width: 13.3 * s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.opponent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        entry.longDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16 * s,
                          height: 1.2,
                          color: AppColors.descGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 1.7 * s),
                  child: Transform.translate(
                    offset: expanded ? Offset(5 * s, 5 * s) : Offset.zero,
                    child: CustomPaint(
                      size: Size(22 * s, 22 * s),
                      painter: _ChevronPainter(
                        up: expanded,
                        color: expanded ? _chevronOpen : const Color(0xFFE6E6E6),
                        width: 1.8 * s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.up, required this.color, required this.width});

  final bool up;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final y1 = up ? h * 0.62 : h * 0.38;
    final y2 = up ? h * 0.38 : h * 0.62;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.12, y1)
        ..lineTo(w * 0.5, y2)
        ..lineTo(w * 0.88, y1),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter old) =>
      old.up != up || old.color != color || old.width != width;
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.entry, required this.size, required this.radius});

  final MatchEntry entry;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    Widget placeholder() => ColoredBox(
          color: const Color(0xFFCCCCCC),
          child: Center(
            child: Icon(Icons.photo_library_outlined, size: size * 0.55, color: const Color(0xFF6A6D6E)),
          ),
        );
    Widget child;
    if (entry.photoPath != null) {
      child = Image.file(File(entry.photoPath!), fit: BoxFit.cover, cacheWidth: px,
          errorBuilder: (_, _, _) => placeholder());
    } else if (entry.photoUrl != null && entry.photoUrl!.isNotEmpty) {
      child = Image.network(entry.photoUrl!, fit: BoxFit.cover, cacheWidth: px,
          errorBuilder: (_, _, _) => placeholder());
    } else {
      child = placeholder();
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

class _OpponentRow extends StatelessWidget {
  const _OpponentRow({required this.entry, required this.scale, required this.onEdit, required this.onDelete});

  final MatchEntry entry;
  final double scale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final item = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 16 * s,
      fontWeight: FontWeight.w500,
      color: AppColors.white,
    );
    PopupMenuItem<_MatchAction> entryItem(_MatchAction a, IconData icon, String text) =>
        PopupMenuItem<_MatchAction>(
          value: a,
          height: 41 * s,
          padding: EdgeInsets.symmetric(horizontal: 18 * s),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22 * s, color: AppColors.white),
              SizedBox(width: 10 * s),
              Text(text, style: item),
            ],
          ),
        );

    return SizedBox(
      height: 48 * s,
      child: Row(
        children: <Widget>[
          Expanded(child: Text('Opponent:', style: _label(s))),
          Flexible(
            child: Text(
              entry.opponent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _value(s),
            ),
          ),
          PopupMenuButton<_MatchAction>(
            tooltip: 'More options',
            color: _popupFill,
            padding: EdgeInsets.zero,
            offset: Offset(0, 36 * s),
            constraints: BoxConstraints(minWidth: 199 * s, maxWidth: 199 * s),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14 * s),
              side: const BorderSide(color: Color(0xFF1E4652)),
            ),
            icon: Icon(Icons.more_vert, size: 22 * s, color: AppColors.white),
            onSelected: (a) => a == _MatchAction.edit ? onEdit() : onDelete(),
            itemBuilder: (_) => <PopupMenuEntry<_MatchAction>>[
              entryItem(_MatchAction.edit, Icons.edit_outlined, 'Edit'),
              const PopupMenuDivider(height: 1),
              entryItem(_MatchAction.delete, Icons.delete_outline, 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.scale});

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      container: true,
      label: '$label $value',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 45 * s,
          child: Row(
            children: <Widget>[
              Flexible(flex: 3, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: _label(s))),
              SizedBox(width: 8 * s),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: _value(s)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
