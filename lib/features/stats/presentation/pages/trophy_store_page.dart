import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_store_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/points_balance_card.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/trophy_card.dart';

/// Trophy Room: points balance + all trophies (tap one to redeem it).
class TrophyStorePage extends GetView<TrophyStoreController> {
  const TrophyStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'Trophy Room',
      navIndex: -1,
      body: Obx(() {
        if (controller.loading.value && controller.trophies.isEmpty) {
          return const AppLoader();
        }
        final error = controller.errorMessage.value;
        if (error != null && controller.trophies.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(error, style: AppTextStyles.programDesc.scaled(s)),
                TextButton(
                  onPressed: controller.load,
                  child: Text(
                    'Try again',
                    style: AppTextStyles.action.scaled(s),
                  ),
                ),
              ],
            ),
          );
        }

        final list = controller.trophies;
        final rows = (list.length + 1) ~/ 2;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: controller.load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(24 * s, 28 * s, 24 * s, 24 * s),
                // +1: the points card is the first item.
                itemCount: rows + 1,
                separatorBuilder: (_, index) =>
                    SizedBox(height: (index == 0 ? 19.3 : 16.3) * s),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return PointsBalanceCard(
                      points: controller.points.value,
                      scale: s,
                      onHistoryTap: controller.openHistory,
                    );
                  }
                  final i = (index - 1) * 2;
                  Widget card(int at) => TrophyCard(
                        trophy: list[at],
                        scale: s,
                        onTap: () => controller.openTrophy(list[at]),
                      );
                  return TrophyGridRow(
                    scale: s,
                    left: card(i),
                    right: i + 1 < list.length ? card(i + 1) : null,
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
