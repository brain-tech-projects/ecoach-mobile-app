import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';

/// A pending invitation from a coach: avatar, name, "position . club" and
/// accept (green) / reject (red) buttons.
class CoachInviteCell extends StatelessWidget {
  const CoachInviteCell({
    super.key,
    required this.invite,
    required this.scale,
    required this.busy,
    required this.locked,
    required this.onAccept,
    required this.onReject,
  });

  final CoachInvite invite;
  final double scale;

  /// This invitation is being answered (spinner instead of the buttons).
  final bool busy;

  /// Another invitation is being answered (buttons disabled).
  final bool locked;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final url = invite.avatarUrl;

    Widget round(IconData icon, Color color, String label, VoidCallback onTap) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: locked ? null : onTap,
        child: Container(
          width: 38 * s,
          height: 38 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 22 * s),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(11 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 54 * s,
              height: 54 * s,
              child: (url == null || url.isEmpty)
                  ? ColoredBox(
                      color: AppColors.cardBorder,
                      child: Icon(Icons.person, color: Colors.white70, size: 30 * s),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.cardBorder,
                        child: Icon(Icons.person, color: Colors.white70, size: 30 * s),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  invite.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w600),
                ),
                if (invite.subtitle.isNotEmpty)
                  Text(
                    invite.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.programDesc.scaled(s),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          if (busy)
            SizedBox(
              width: 38 * s,
              height: 38 * s,
              child: Padding(
                padding: EdgeInsets.all(8 * s),
                child: const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accent),
              ),
            )
          else ...<Widget>[
            round(Icons.check, const Color(0xFF3DC46B), 'Accept invitation', onAccept),
            SizedBox(width: 10 * s),
            round(Icons.close, const Color(0xFFE24B4B), 'Reject invitation', onReject),
          ],
        ],
      ),
    );
  }
}
