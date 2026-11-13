import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/add_training_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

/// Add New Training: choose source -> pick eCoach video / upload own -> submitted.
class AddTrainingPage extends GetView<AddTrainingController> {
  const AddTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;

    return Obx(() {
      final step = controller.step.value;
      return SubPageScaffold(
        title: step == 2 ? 'Add Training Videos' : 'Add New Training',
        navIndex: 3,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 24 * s),
          child: switch (step) {
            0 => _ChooseStep(controller: controller, scale: s),
            1 => controller.isEcoach ? _EcoachStep(controller: controller, scale: s) : _OwnStep(controller: controller, scale: s),
            _ => _DoneStep(controller: controller, scale: s),
          },
        ),
      );
    });
  }
}

class _ChooseStep extends StatelessWidget {
  const _ChooseStep({required this.controller, required this.scale});
  final AddTrainingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget option(String letter, String label, TrainingSource value) {
      final selected = controller.source.value == value;
      return Padding(
        padding: EdgeInsets.only(bottom: 14 * s),
        child: Material(
          color: selected ? AppColors.selectedFill : AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * s), side: BorderSide(color: selected ? AppColors.selectGreen : AppColors.cardBorder, width: selected ? 1.5 : 1)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14 * s),
            onTap: () => controller.choose(value),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32 * s,
                    height: 32 * s,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.selectGreen : Colors.transparent, border: Border.all(color: AppColors.accent, width: 1.5)),
                    child: Text(letter, style: AppTextStyles.programTitle.scaled(s).copyWith(color: selected ? AppColors.black : AppColors.white, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(width: 18 * s),
                  Expanded(child: Text(label, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400))),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Would you like to upload your own training session, or use an eCoach training video?', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 21 * s, fontWeight: FontWeight.w400)),
          SizedBox(height: 22 * s),
          option('A', 'Use an eCoach training video', TrainingSource.ecoach),
          option('B', 'Upload my own training video', TrainingSource.own),
          SizedBox(height: 4 * s),
          CoachButtonRow(
            children: <Widget>[
              CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, minWidth: 130, onTap: controller.cancel),
              CoachButton(label: 'Save & Next', minWidth: 130, enabled: controller.source.value != null, onTap: controller.next),
            ],
          ),
        ],
      ),
    );
  }
}

class _EcoachStep extends StatelessWidget {
  const _EcoachStep({required this.controller, required this.scale});
  final AddTrainingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Obx(() {
      final cat = controller.category.value;
      final drill = controller.drill.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CoachDropdown<SkillItem>(
            hint: 'Select Skill',
            value: cat,
            loading: controller.loadingCategories.value,
            items: <CoachPickItem<SkillItem>>[for (final c in controller.categories) CoachPickItem<SkillItem>(value: c, label: c.name, imageUrl: c.imageUrl)],
            onChanged: controller.selectCategory,
          ),
          if (cat != null) ...<Widget>[
            SizedBox(height: 16 * s),
            CoachDropdown<DrillItem>(
              key: ValueKey<int>(cat.id),
              hint: 'Select Training',
              searchHint: 'Search & Select Training Video',
              value: drill,
              items: <CoachPickItem<DrillItem>>[for (final d in controller.drills) CoachPickItem<DrillItem>(value: d, label: d.title)],
              onChanged: controller.selectDrill,
            ),
          ],
          if (drill != null) ...<Widget>[
            SizedBox(height: 16 * s),
            AppVideoPlayer(key: ValueKey<int>(drill.id), url: drill.videoUrl, height: 220, scale: s),
          ],
          SizedBox(height: 20 * s),
          CoachButtonRow(
            children: <Widget>[
              CoachButton(label: 'Previous', kind: CoachButtonKind.outline, minWidth: 130, onTap: controller.previous),
              CoachButton(label: 'Submit', minWidth: 130, enabled: controller.canSubmit, loading: controller.submitting.value, onTap: controller.submit),
            ],
          ),
        ],
      );
    });
  }
}

class _OwnStep extends StatelessWidget {
  const _OwnStep({required this.controller, required this.scale});
  final AddTrainingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final label = AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w400);
    return Obx(() {
      final path = controller.videoPath.value;
      final busy = controller.submitting.value;
      final pct = (controller.progress.value * 100).round();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: busy ? null : controller.pickVideo,
            child: DashedBox(
              radius: 14 * s,
              child: Container(
                height: 125 * s,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14 * s)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.photo_camera_outlined, size: 32 * s, color: AppColors.white),
                    SizedBox(height: 8 * s),
                    Text('Upload Training Video', style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4 * s),
                    Text('Supported formats: .mp4', style: AppTextStyles.programDesc.scaled(s)),
                  ],
                ),
              ),
            ),
          ),
          if (path != null) ...<Widget>[
            SizedBox(height: 12 * s),
            AppVideoPlayer(key: ValueKey<String>(path), url: path, height: 220, scale: s),
          ],
          if (busy) ...<Widget>[
            SizedBox(height: 14 * s),
            Row(
              children: <Widget>[
                Expanded(child: Text(pct == 0 ? 'Preparing upload, please wait...' : 'Uploading, please wait...', style: label)),
                Text('$pct%', style: label.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(height: 8 * s),
            ClipRRect(
              borderRadius: BorderRadius.circular(8 * s),
              child: LinearProgressIndicator(value: controller.progress.value, minHeight: 8 * s, backgroundColor: const Color(0xFFEDEDED), color: AppColors.accent),
            ),
          ],
          SizedBox(height: 22 * s),
          Text('Training Name :', style: label),
          SizedBox(height: 10 * s),
          CoachTextField(controller: controller.title, hint: 'Enter Training Name (Optional)'),
          SizedBox(height: 22 * s),
          Text('Description :', style: label),
          SizedBox(height: 10 * s),
          CoachTextField(controller: controller.description, hint: 'Enter Description (Optional)', maxLines: 4),
          SizedBox(height: 20 * s),
          CoachButtonRow(
            children: <Widget>[
              CoachButton(label: 'Previous', kind: CoachButtonKind.outline, minWidth: 130, enabled: !busy, onTap: controller.previous),
              CoachButton(label: 'Submit', minWidth: 130, enabled: controller.canSubmit, loading: false, onTap: controller.submit),
            ],
          ),
        ],
      );
    });
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.controller, required this.scale});
  final AddTrainingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(top: 90 * s),
      child: Column(
        children: <Widget>[
          Container(
            width: 100 * s,
            height: 100 * s,
            decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 2)),
            child: Icon(Icons.fact_check_outlined, size: 54 * s, color: AppColors.headerBg),
          ),
          SizedBox(height: 36 * s),
          Text('Training Program Submitted Successfully', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 26 * s, height: 1.45)),
          SizedBox(height: 28 * s),
          GestureDetector(
            onTap: controller.seeAll,
            child: Text('See All Training Programs', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 19 * s, color: AppColors.accent, decoration: TextDecoration.underline, decorationColor: AppColors.accent)),
          ),
          SizedBox(height: 44 * s),
          Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16 * s),
            child: InkWell(
              borderRadius: BorderRadius.circular(16 * s),
              onTap: controller.finish,
              child: SizedBox(
                width: double.infinity,
                height: 44 * s,
                child: Center(child: Text('Done', style: AppTextStyles.buttonLabel.scaled(s).copyWith(color: AppColors.black, fontWeight: FontWeight.w600))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
