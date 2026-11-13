import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/team_form_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

/// Add New Team / Edit Team.
class TeamFormPage extends GetView<TeamFormController> {
  const TeamFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    final label = AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 17 * s);

    return SubPageScaffold(
      title: controller.isEdit ? 'Edit Team' : 'Add New Team',
      navIndex: 0,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(hPad, 22 * s, hPad, 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Obx(() {
              final path = controller.imagePath.value;
              final existing = controller.existingImage;
              return GestureDetector(
                onTap: controller.pickImage,
                child: DashedBox(
                  radius: 14 * s,
                  child: Container(
                    height: 125 * s,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14 * s)),
                    child: path != null
                        ? Image.file(File(path), fit: BoxFit.cover)
                        : (existing != null)
                        ? coachImage(existing, _UploadHint(scale: s))
                        : _UploadHint(scale: s),
                  ),
                ),
              );
            }),
            SizedBox(height: 14 * s),
            Text('Team Name :', style: label),
            SizedBox(height: 10 * s),
            Obx(() => CoachTextField(controller: controller.name, hint: 'Enter Team Name', errorText: controller.nameError.value)),
            SizedBox(height: 22 * s),
            Text('Description :', style: label),
            SizedBox(height: 10 * s),
            CoachTextField(controller: controller.description, hint: 'Enter Description', maxLines: 4),
            SizedBox(height: 20 * s),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.name,
              builder: (_, v, _) => Obx(
                () => CoachButtonRow(
                  children: <Widget>[
                    CoachButton(label: 'Cancel', kind: CoachButtonKind.outline, minWidth: 130, onTap: () => Get.back<void>()),
                    CoachButton(label: 'Submit', minWidth: 130, enabled: v.text.trim().isNotEmpty, loading: controller.saving.value, onTap: controller.submit),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadHint extends StatelessWidget {
  const _UploadHint({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.photo_camera_outlined, size: 32 * s, color: AppColors.white),
        SizedBox(height: 8 * s),
        Text('Upload Team Image', style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 17 * s, fontWeight: FontWeight.w600)),
        SizedBox(height: 4 * s),
        Text('JPG , PNG formats up to 20MB', style: AppTextStyles.programDesc.scaled(s)),
      ],
    );
  }
}
