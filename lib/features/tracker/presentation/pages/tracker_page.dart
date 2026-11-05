import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/tracker/presentation/controllers/tracker_controller.dart';
import 'package:ecoach_pro/features/tracker/presentation/widgets/match_card.dart';
import 'package:ecoach_pro/features/tracker/presentation/widgets/tracker_header.dart';

/// Tracker tab: player summary, averages and rated matches.
class TrackerPage extends GetView<TrackerController> {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Rating Tracker',
      navIndex: 4,
      floatingAction: Padding(
        padding: EdgeInsets.only(right: 5.3 * s, bottom: 6.7 * s),
        child: _AddButton(scale: s, onTap: controller.openAdd),
      ),
      body: Obx(() {
        if (controller.loading.value && controller.data.value == null) return const AppLoader();
        final error = controller.errorMessage.value;
        final data = controller.data.value;
        if (error != null || data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(error ?? 'Could not load your tracker.', style: AppTextStyles.programDesc.scaled(s)),
                TextButton(
                  onPressed: controller.load,
                  child: Text('Retry', style: AppTextStyles.action.scaled(s)),
                ),
              ],
            ),
          );
        }

        final entries = controller.visibleEntries;
        final open = Set<String>.of(controller.expanded);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: controller.load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 29 * s, hPad, 0),
                    sliver: SliverToBoxAdapter(child: TrackerSummary(data: data, scale: s)),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 24.3 * s, hPad, 0),
                    sliver: SliverToBoxAdapter(child: RatingsStrip(data: data, scale: s)),
                  ),
                  if (data.years.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 14.3 * s, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: YearTabs(
                          years: data.years,
                          selected: controller.selectedYear.value,
                          onChanged: (y) => controller.selectedYear.value = y,
                          scale: s,
                        ),
                      ),
                    ),
                  if (entries.isEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 0),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No matches tracked yet. Tap + to rate your first match.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.programDesc.scaled(s),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 17 * s, hPad, 96 * s),
                      sliver: SliverList.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => SizedBox(height: 16.3 * s),
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          return MatchCard(
                            entry: e,
                            expanded: open.contains(e.id),
                            scale: s,
                            onToggle: () => controller.toggle(e.id),
                            onEdit: () => controller.openEdit(e),
                            onDelete: () => controller.deleteMatch(e),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = 54.7 * scale;
    return Semantics(
      button: true,
      label: 'Add match rating',
      child: Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF69F675), Color(0xFF349E24)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: Icon(Icons.add, size: 36 * scale, color: AppColors.black, weight: 700)),
          ),
        ),
      ),
    );
  }
}
