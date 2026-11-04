import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';

const Color _outerFill = Color(0xFF2A3A40);
const Color _innerFill = Color(0xFF435259);
const Color _chevronOpen = Color(0xFFF1D9A5);
const Color _deleteFill = Color(0xFF785051);

/// Expandable card of the Notes page. A node can hold child cards (skill
/// area > drill) and / or notes.
class NoteNodeCard extends StatelessWidget {
  const NoteNodeCard({
    super.key,
    required this.node,
    required this.scale,
    required this.isExpanded,
    required this.onToggle,
    required this.onDeleteNote,
    this.nested = false,
  });

  final NoteNode node;
  final double scale;
  final bool nested;
  final bool Function(String id) isExpanded;
  final ValueChanged<String> onToggle;
  final ValueChanged<NoteEntry> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final open = isExpanded(node.id);
    final divider = nested ? const Color(0xFF697579) : const Color(0xFF576468);

    return Semantics(
      container: true,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.fromLTRB(11 * s, 10.5 * s, 11 * s, 10.5 * s),
          decoration: BoxDecoration(
            color: nested ? _innerFill : _outerFill,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(node: node, scale: s, nested: nested, open: open, onTap: () => onToggle(node.id)),
              if (open) ...<Widget>[
                SizedBox(height: 15.2 * s),
                Divider(height: 1, thickness: 1, color: divider),
                if (node.children.isNotEmpty) ...<Widget>[
                  SizedBox(height: 17 * s),
                  for (var i = 0; i < node.children.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(height: 8 * s),
                    NoteNodeCard(
                      node: node.children[i],
                      scale: s,
                      nested: true,
                      isExpanded: isExpanded,
                      onToggle: onToggle,
                      onDeleteNote: onDeleteNote,
                    ),
                  ],
                  SizedBox(height: 8.5 * s),
                ],
                for (var i = 0; i < node.notes.length; i++)
                  _NoteBlock(
                    note: node.notes[i],
                    scale: s,
                    last: i == node.notes.length - 1,
                    dividerColor: divider,
                    onDelete: () => onDeleteNote(node.notes[i]),
                  ),
                if (node.children.isEmpty && node.notes.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14 * s),
                    child: Text(
                      'No notes yet.',
                      style: AppTextStyles.programDesc.scaled(s),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.node,
    required this.scale,
    required this.nested,
    required this.open,
    required this.onTap,
  });

  final NoteNode node;
  final double scale;
  final bool nested;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      expanded: open,
      label: node.title,
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * s),
        onTap: onTap,
        child: SizedBox(
          height: 45 * s,
          child: Row(
            children: <Widget>[
              ThumbImage(source: node.thumbnail, size: 45 * s, radius: 10 * s),
              SizedBox(width: (nested ? 13 : 16) * s),
              Expanded(
                child: Text(
                  node.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.menuItem.scaled(s).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 1.7 * s),
                child: Transform.translate(
                  offset: open ? Offset(5 * s, 5 * s) : Offset.zero,
                  child: ThinChevron(
                    up: open,
                    color: open ? _chevronOpen : const Color(0xFFE6E6E6),
                    scale: s,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.note,
    required this.scale,
    required this.last,
    required this.dividerColor,
    required this.onDelete,
  });

  final NoteEntry note;
  final double scale;
  final bool last;
  final Color dividerColor;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final base = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 15 * s,
      height: 1.4,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 17 * s, 0, (last ? 12.5 : 16.7) * s),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(note.text, style: base.copyWith(color: AppColors.descGrey)),
                    if (note.date != null) ...<Widget>[
                      SizedBox(height: 5.7 * s),
                      Text(PlayerFormat.noteDate(note.date!),
                          style: base.copyWith(color: AppColors.white)),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8 * s),
              Padding(
                padding: EdgeInsets.only(top: 17 * s),
                child: Semantics(
                  button: true,
                  label: 'Delete note',
                  child: Material(
                    color: _deleteFill,
                    borderRadius: BorderRadius.circular(12 * s),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12 * s),
                      onTap: onDelete,
                      child: SizedBox(
                        width: 40 * s,
                        height: 40 * s,
                        child: Center(child: RemoveIcon(size: 24 * s)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}
