import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/personal_training/presentation/controllers/personal_training_controller.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Personal Training Session: intro + "Add Skills", then the saved drills as
/// a two-column grid with a "Remove" menu on every card.
class PersonalTrainingPage extends GetView<PersonalTrainingController> {
  const PersonalTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Personal Training Session',
      body: Obx(() {
        if (controller.loading.value && controller.drills.isEmpty) {
          return const AppLoader();
        }
        final error = controller.errorMessage.value;
        if (error != null && controller.drills.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(error, style: AppTextStyles.programDesc.scaled(s)),
                TextButton(
                  onPressed: controller.load,
                  child: Text('Retry', style: AppTextStyles.action.scaled(s)),
                ),
              ],
            ),
          );
        }

        final items = controller.drills.toList();
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 27 * s, hPad, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Create your own personalised training program by '
                        'adding sessions from the skills area.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.trainSubline.scaled(s),
                      ),
                      SizedBox(height: 14 * s),
                      Text(
                        'Simply tap the three dots and add to My Personal '
                        'Training.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.trainSubline.scaled(s),
                      ),
                      SizedBox(height: 18 * s),
                      _GreenPill(
                        label: 'Add Skills',
                        scale: s,
                        onTap: controller.addSkills,
                      ),
                      SizedBox(height: 20 * s),
                      Divider(color: AppColors.cardBorder, height: 1 * s),
                      SizedBox(height: 18 * s),
                      if (items.isNotEmpty)
                        Row(
                          children: <Widget>[
                            Text(
                              '${items.length} Item${items.length == 1 ? '' : 's'}',
                              style: AppTextStyles.programTitle.scaled(s),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: controller.playAll,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 20 * s,
                                    color: AppColors.selectGreen,
                                  ),
                                  SizedBox(width: 6 * s),
                                  Text(
                                    'Play All',
                                    style: AppTextStyles.action.scaled(s),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'No sessions added yet.',
                          style: AppTextStyles.programDesc.scaled(s),
                        ),
                      SizedBox(height: 16 * s),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24 * s),
                sliver: SliverGrid.builder(
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12 * s,
                    mainAxisSpacing: 12 * s,
                    mainAxisExtent: 196 * s,
                  ),
                  itemBuilder: (context, i) => _DrillTile(
                    drill: items[i],
                    scale: s,
                    onTap: () => controller.openDrill(items[i]),
                    onRemove: () => controller.remove(items[i]),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _GreenPill extends StatelessWidget {
  const _GreenPill({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.selectGreen,
    shape: const StadiumBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 9 * scale),
        child: Text(label, style: AppTextStyles.heroButton.scaled(scale)),
      ),
    ),
  );
}

class _DrillTile extends StatelessWidget {
  const _DrillTile({
    required this.drill,
    required this.scale,
    required this.onTap,
    required this.onRemove,
  });

  final Drill drill;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  Future<void> _menu(BuildContext anchor) async {
    final box = anchor.findRenderObject() as RenderBox;
    final overlay = Overlay.of(anchor).context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final value = await showMenu<bool>(
      context: anchor,
      color: AppColors.dialogBg,
      position: RelativeRect.fromLTRB(
        topLeft.dx - 150 * scale,
        topLeft.dy + box.size.height,
        overlay.size.width - topLeft.dx - box.size.width,
        0,
      ),
      items: <PopupMenuEntry<bool>>[
        PopupMenuItem<bool>(
          value: true,
          child: Row(
            children: <Widget>[
              Icon(Icons.delete_outline, size: 18 * scale, color: AppColors.white),
              SizedBox(width: 10 * scale),
              Flexible(
                child: Text(
                  'Remove from Personal Training Session',
                  style: AppTextStyles.menuItem.scaled(scale * 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (value == true) onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final fallback = const ColoredBox(color: AppColors.ringTrack);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 96 * s,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  drill.thumbnail.isEmpty
                      ? fallback
                      : Image.network(
                          drill.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => fallback,
                        ),
                  Center(
                    child: Container(
                      width: 36 * s,
                      height: 36 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.selectGreen.withValues(alpha: 0.55),
                      ),
                      child: Icon(Icons.play_arrow, color: AppColors.white, size: 24 * s),
                    ),
                  ),
                  Positioned(
                    top: 2 * s,
                    right: 2 * s,
                    child: Builder(
                      builder: (anchor) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _menu(anchor),
                        child: SizedBox(
                          width: 30 * s,
                          height: 30 * s,
                          child: Icon(
                            Icons.more_horiz,
                            size: 22 * s,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 8 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    drill.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.programTitle.scaled(s * 0.85),
                  ),
                  SizedBox(height: 4 * s),
                  Text(
                    drill.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.programDesc.scaled(s * 0.85),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
