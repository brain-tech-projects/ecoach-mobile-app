import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/player_detail_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';
import 'package:ecoach_pro/features/dashboard/presentation/widgets/profile_card.dart';

class PlayerDetailPage extends GetView<PlayerDetailController> {
  const PlayerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    final p = controller.player;
    final gap = SizedBox(width: 8.7 * s);

    Widget row(Widget a, Widget b) => Padding(
      padding: EdgeInsets.only(bottom: 8.7 * s),
      child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[Expanded(child: a), gap, Expanded(child: b)])),
    );

    return SubPageScaffold(
      title: p.name,
      navIndex: 1,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.card,
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 21 * s, hPad, 24 * s),
          children: <Widget>[
            ProfileCard(name: p.name, subtitle: p.subtitle, photoUrl: p.photoUrl, flag: coachFlag(p.countryCode), scale: s),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 28 * s, 0, 12 * s),
              child: Semantics(header: true, child: Text('Quick Stats', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 18 * s))),
            ),
            Obx(() {
              final st = controller.stats.value;
              return Column(
                children: <Widget>[
                  row(
                    CoachStatTile(icon: Icons.fact_check_outlined, value: '${st.sessions}', label: 'Sessions Completed'),
                    CoachStatTile(icon: Icons.assignment_turned_in_outlined, value: '${st.skills}', label: 'Skills Attempted'),
                  ),
                  row(
                    CoachStatTile(icon: Icons.quiz_outlined, value: '${st.quizzes}', label: 'Quizzes Taken'),
                    CoachStatTile(icon: Icons.update_rounded, value: '${st.tracker}', label: 'Tracker Updates'),
                  ),
                ],
              );
            }),
            SizedBox(height: 18 * s),
            CoachNotifyCard(onTap: controller.notify),
          ],
        ),
      ),
    );
  }
}
