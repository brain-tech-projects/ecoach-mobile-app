import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';

/// Connected coach: round photo, name, team and a red "Disconnect" button.
class CoachCard extends StatelessWidget {
  const CoachCard({
    super.key,
    required this.coach,
    required this.scale,
    required this.busy,
    required this.onDisconnect,
  });

  final Coach coach;
  final double scale;
  final bool busy;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      padding: EdgeInsets.fromLTRB(11 * s, 10.7 * s, 11 * s, 10.7 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Avatar(coach: coach, size: 55 * s),
          SizedBox(width: 8 * s),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    coach.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.white,
                    ).scaled(s),
                  ),
                  Text(
                    coach.team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.descGrey,
                    ).scaled(s),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          Semantics(
            button: true,
            label: 'Disconnect from ${coach.name}',
            child: ExcludeSemantics(
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * s),
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10 * s),
                  onTap: busy ? null : onDisconnect,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 96 * s, minHeight: 30.7 * s),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8 * s),
                    child: busy
                        ? SizedBox(
                            width: 16 * s,
                            height: 16 * s,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.error,
                            ),
                          )
                        : Text(
                            'Disconnect',
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: AppColors.error,
                            ).scaled(s),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.coach, required this.size});

  final Coach coach;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => ColoredBox(
          color: AppColors.avatarBg,
          child: Icon(Icons.person, size: size * 0.6, color: AppColors.avatarFg),
        );

    Widget image;
    if (coach.avatarAsset != null) {
      image = Image.asset(
        coach.avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else if (coach.avatarUrl != null) {
      image = Image.network(
        coach.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else {
      image = fallback();
    }

    return ExcludeSemantics(
      child: SizedBox(width: size, height: size, child: ClipOval(child: image)),
    );
  }
}
