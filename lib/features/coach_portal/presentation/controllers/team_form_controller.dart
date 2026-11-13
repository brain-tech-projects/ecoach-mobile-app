import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/tracker/data/repositories/image_picker_photo_picker.dart';

/// Add New Team / Edit Team (arguments: CoachTeam? to edit).
class TeamFormController extends GetxController {
  final CoachTeam? editing = Get.arguments is CoachTeam ? Get.arguments as CoachTeam : null;

  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final RxnString imagePath = RxnString();
  final RxBool saving = false.obs;
  final RxnString nameError = RxnString();

  bool get isEdit => editing != null;
  String? get existingImage => editing?.imageUrl;

  @override
  void onInit() {
    super.onInit();
    name.text = editing?.name ?? '';
    description.text = editing?.description ?? '';
  }

  Future<void> pickImage() async {
    final path = await ImagePickerMatchPhotoPicker().pick();
    if (path != null) imagePath.value = path;
  }

  Future<void> submit() async {
    if (saving.value) return;
    if (name.text.trim().isEmpty) {
      nameError.value = 'The Team Name field is required.';
      AppToast.error(nameError.value!);
      return;
    }
    nameError.value = null;
    FocusManager.instance.primaryFocus?.unfocus();
    saving.value = true;
    final ok = await coachRun(
      () => Get.find<CoachPortalRepository>().saveTeam(id: editing?.id, name: name.text.trim(), description: description.text.trim(), imagePath: imagePath.value),
      success: isEdit ? 'Team updated successfully' : 'Team created successfully',
    );
    saving.value = false;
    if (ok) Get.back<void>();
  }

  @override
  void onClose() {
    name.dispose();
    description.dispose();
    super.onClose();
  }
}
