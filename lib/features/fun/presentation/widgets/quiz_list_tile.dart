import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// Row with a round logo and a title (quiz groups and quizzes).
class QuizListTile extends StatelessWidget {
  const QuizListTile({
    super.key,
    required this.title,
    required this.logo,
    required this.scale,
    required this.onTap,
  });

  final String title;
  final String logo;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.5 * s),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.5 * s)),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 70.7 * s),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.3 * s, 7 * s, 12 * s, 7 * s),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 54.7 * s,
                    height: 54.7 * s,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ClipOval(child: FunImage(logo)),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.3 * s),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.drillTitle.scaled(s),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
