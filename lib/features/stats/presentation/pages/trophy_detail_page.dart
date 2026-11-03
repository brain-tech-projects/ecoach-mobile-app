import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_detail_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/trophy_art.dart';

/// One trophy: big picture, name, points and the Redeem button.
class TrophyDetailPage extends GetView<TrophyDetailController> {
  const TrophyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final trophy = controller.trophy;

    const titleStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: AppColors.white,
    );

    return SubPageScaffold(
      title: trophy.name,
      navIndex: -1,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1035 / 710,
                  child: TrophyArt(trophy: trophy, radius: 24 * s, hero: true),
                ),
                SizedBox(height: 12.3 * s),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(trophy.name, style: titleStyle.scaled(s)),
                          Text(
                            '${trophy.points} Points',
                            style: titleStyle
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                )
                                .scaled(s),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Padding(
                      padding: EdgeInsets.only(top: 4 * s),
                      child: Semantics(
                        button: true,
                        label: 'Redeem ${trophy.name}',
                        child: ExcludeSemantics(
                          child: Material(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12 * s),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12 * s),
                              onTap: controller.onRedeemTap,
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: 97 * s,
                                  minHeight: 32 * s,
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 16 * s),
                                child: Text(
                                  'Redeem',
                                  style: AppTextStyles.buttonLabelSmall.scaled(s),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
