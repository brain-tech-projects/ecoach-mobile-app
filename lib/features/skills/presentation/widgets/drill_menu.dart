import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/floating_panel.dart';

/// The "⋮" popup of a drill: add to personal session / My Skills / add note.
/// Opens below the anchor (above it when there is no room).
Future<void> showDrillMenu(
  BuildContext anchor, {
  required double scale,
  required VoidCallback onAddToSession,
  required VoidCallback onAddToMySkills,
  required VoidCallback onAddNote,
}) {
  final box = anchor.findRenderObject()! as RenderBox;
  final origin = box.localToGlobal(Offset.zero);
  final screen = MediaQuery.sizeOf(anchor);
  final panelHeight = 123.7 * scale;
  final reservedBottom = 90 * scale; // floating tab bar

  final below = origin.dy + box.size.height + 6 * scale;
  final fitsBelow = below + panelHeight < screen.height - reservedBottom;

  return showFloatingPanel<void>(
    anchor,
    width: 198 * scale,
    right: screen.width - (origin.dx + box.size.width),
    top: fitsBelow ? below : null,
    bottom: fitsBelow ? null : screen.height - origin.dy + 6 * scale,
    builder: (dialogContext) {
      void run(VoidCallback action) {
        Navigator.of(dialogContext).pop();
        action();
      }

      return _MenuPanel(
        scale: scale,
        onAddToSession: () => run(onAddToSession),
        onAddToMySkills: () => run(onAddToMySkills),
        onAddNote: () => run(onAddNote),
      );
    },
  );
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.scale,
    required this.onAddToSession,
    required this.onAddToMySkills,
    required this.onAddNote,
  });

  final double scale;
  final VoidCallback onAddToSession;
  final VoidCallback onAddToMySkills;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: AppColors.popupBg,
      elevation: 8,
      borderRadius: BorderRadius.circular(8 * s),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Item(
            label: 'Add to Personal Training Session',
            height: 54.7 * s,
            scale: s,
            onTap: onAddToSession,
          ),
          Container(height: 1 * s, color: AppColors.popupDivider),
          SizedBox(height: 6.3 * s),
          _Item(label: 'Add to My Skills', height: 26 * s, scale: s, onTap: onAddToMySkills),
          _Item(label: 'Add Note', height: 26 * s, scale: s, onTap: onAddNote),
          SizedBox(height: 3.3 * s),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.height,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double height;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Row(
          children: <Widget>[
            SizedBox(width: 17.7 * s),
            Icon(Icons.add_circle_outline, size: 14.7 * s, color: AppColors.white),
            SizedBox(width: 10 * s),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 12 * s),
                child: Text(label, style: AppTextStyles.popupItem.scaled(s)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
