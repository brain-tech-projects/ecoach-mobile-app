import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/programs_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

class ProgramsPage extends GetView<ProgramsController> {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return SubPageScaffold(
      title: 'Training Programs',
      navIndex: 3,
      floatingAction: CoachFab(onTap: controller.openAdd, label: 'Add training'),
      body: Obx(() {
        if (controller.loading.value && controller.programs.isEmpty) return const AppLoader();
        final error = controller.errorMessage.value;
        if (error != null && controller.programs.isEmpty) return Center(child: CoachEmpty(text: error, onRetry: controller.load));
        final list = controller.programs.toList();
        return RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: controller.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 90 * s),
            itemCount: list.length + 1,
            separatorBuilder: (_, _) => SizedBox(height: 14 * s),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6 * s),
                  child: Text('Explore all training modules and add new programs anytime.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400)),
                );
              }
              return _ProgramCard(
                program: list[i - 1],
                onAddPlayers: () => controller.addPlayers(list[i - 1]),
                onEdit: () => controller.edit(list[i - 1]),
                onRemove: () => controller.remove(list[i - 1]),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program, required this.onAddPlayers, required this.onEdit, required this.onRemove});
  final TrainingProgram program;
  final VoidCallback onAddPlayers;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return CoachCard(
      padding: EdgeInsets.fromLTRB(12 * s, 8 * s, 6 * s, 14 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(program.title, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w600))),
              SizedBox(
                width: 36 * s,
                height: 36 * s,
                child: CoachKebab(entries: <CoachMenuEntry>[
                  CoachMenuEntry('Add Players', Icons.person_add_alt_1_outlined, onAddPlayers),
                  CoachMenuEntry('Edit', Icons.edit_outlined, onEdit),
                  CoachMenuEntry('Remove', Icons.delete_outline, onRemove),
                ]),
              ),
            ],
          ),
          SizedBox(height: 4 * s),
          CoachPill(label: '${program.playerCount} Players', icon: Icons.people_outline),
        ],
      ),
    );
  }
}
