import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/stats/presentation/controllers/trophy_room_controller.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/point_history_card.dart';

class TrophyRoomPage extends GetView<TrophyRoomController> {
  const TrophyRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return SubPageScaffold(
      title: 'Trophy Room',
      navIndex: -1,
      body: Obx(() {
        if (controller.loading.value) return const AppLoader();
        return _Body(controller: controller, scale: r.scale);
      }),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.scale});

  final TrophyRoomController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = scale;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
        child: Obx(() {
          final historyTab = controller.selectedTab.value == 0;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24 * s, 22 * s, 24 * s, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _Tab(
                            label: 'Points History',
                            selected: historyTab,
                            scale: s,
                            onTap: () => controller.selectedTab.value = 0,
                          ),
                          _Tab(
                            label: 'My Trophies',
                            selected: !historyTab,
                            scale: s,
                            onTap: () => controller.selectedTab.value = 1,
                          ),
                        ],
                      ),
                      SizedBox(height: 14 * s),
                      const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
                    ],
                  ),
                ),
              ),
              if (historyTab)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(21 * s, 33 * s, 21 * s, 20 * s),
                  sliver: SliverList.separated(
                    itemCount: controller.history.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14 * s),
                    itemBuilder: (context, index) => PointHistoryCard(
                      entry: controller.history[index],
                      scale: s,
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * s),
                      child: Text(
                        'No trophies earned yet.',
                        style: AppTextStyles.programDesc.scaled(s),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.scale, required this.onTap});

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.white,
              ).scaled(s).copyWith(color: selected ? AppColors.accent : AppColors.white),
            ),
            SizedBox(height: 13 * s),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3 * s,
              color: selected ? AppColors.accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
