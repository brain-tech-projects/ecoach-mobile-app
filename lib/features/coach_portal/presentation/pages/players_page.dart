import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/players_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

class PlayersPage extends GetView<PlayersController> {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Players',
      navIndex: 1,
      floatingAction: CoachFab(onTap: controller.invite, label: 'Invite player'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 14 * s),
            child: CoachSearchField(hint: 'Search players', onChanged: (v) => controller.query.value = v),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.players.isEmpty) return const AppLoader();
              final error = controller.errorMessage.value;
              if (error != null && controller.players.isEmpty) return Center(child: CoachEmpty(text: error, onRetry: controller.load));
              final list = controller.filtered;
              return RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.card,
                onRefresh: controller.load,
                child: list.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: <Widget>[_NoPlayers(scale: s)],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 90 * s),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12 * s),
                        itemBuilder: (_, i) => CoachPlayerTile(player: list[i], onTap: () => controller.openDetail(list[i])),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// "No Players Found" empty state (search without results / no players yet).
class _NoPlayers extends StatelessWidget {
  const _NoPlayers({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 4 * s, 24 * s, 24 * s),
      child: Column(
        children: <Widget>[
          Semantics(header: true, child: Text('No Players Found', textAlign: TextAlign.center, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 15 * s, fontWeight: FontWeight.w600))),
          SizedBox(height: 8 * s),
          Text('Please invite a player using the plus (+) button and their email address.', textAlign: TextAlign.center, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 12 * s, fontWeight: FontWeight.w400, height: 1.5)),
        ],
      ),
    );
  }
}
