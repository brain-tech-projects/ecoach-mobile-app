import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/fun/data/fun_assets.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/fun_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_hub_tile.dart';

/// Fun tab hub: Challenges / Quizzes.
class FunPage extends GetView<FunController> {
  const FunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    return SubPageScaffold(
      title: 'Fun',
      navIndex: MainNav.funIndex,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 28.3 * s, hPad, 24 * s),
        child: Column(
          children: <Widget>[
            Text(
              'Ready for a fun challenge? Or test yourself with a quiz?',
              textAlign: TextAlign.center,
              style: AppTextStyles.trainSubline.scaled(s),
            ),
            SizedBox(height: 38.3 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: FunHubTile(label: 'Challenges', asset: FunAssets.hubChallenges, scale: s, onTap: controller.openChallenges),
                ),
                SizedBox(width: 8.3 * s),
                Expanded(
                  child: FunHubTile(label: 'Quizzes', asset: FunAssets.hubQuizzes, scale: s, onTap: controller.openQuizzes),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
