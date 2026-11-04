import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/widgets/floating_panel.dart';

/// Global rectangle of [context]'s render box (iPad share-sheet anchor).
Rect? globalRectOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// "Add Note / Share" panel drawn over the lower part of a challenge card.
Future<void> showChallengeMenu(
  BuildContext cardContext, {
  required double scale,
  required VoidCallback onAddNote,
  required VoidCallback onShare,
}) {
  final rect = globalRectOf(cardContext);
  if (rect == null) return Future<void>.value();
  final s = scale;
  final left = rect.left + 3 * s;
  return showFloatingPanel<void>(
    cardContext,
    left: left,
    top: rect.top + 29.7 * s,
    width: rect.right - left - 1,
    builder: (dialogContext) {
      void run(VoidCallback action) {
        Navigator.of(dialogContext).pop();
        action();
      }

      return Container(
        padding: EdgeInsets.fromLTRB(0, 7 * s, 0, 9.3 * s),
        decoration: BoxDecoration(
          color: AppColors.popupBg,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Item(icon: Icons.add_circle_outline, label: 'Add Note', scale: s, onTap: () => run(onAddNote)),
            _Item(icon: Icons.ios_share, label: 'Share', scale: s, onTap: () => run(onShare)),
          ],
        ),
      );
    },
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.scale, required this.onTap});

  final IconData icon;
  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 26 * scale,
      child: Row(
        children: <Widget>[
          SizedBox(width: 17.7 * scale),
          Icon(icon, size: 14.7 * scale, color: Colors.white),
          SizedBox(width: 9.5 * scale),
          Text(label, style: AppTextStyles.popupItem.scaled(scale)),
        ],
      ),
    ),
  );
}
