import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/tracker/data/repositories/image_picker_photo_picker.dart';

/// Coach My Profile (dummy data; replace _seed/save with API later).
class CoachProfileController extends GetxController {
  final TextEditingController profileName = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController team = TextEditingController();
  final TextEditingController position = TextEditingController();

  final RxString country = 'IN'.obs;
  final Rxn<DateTime> dob = Rxn<DateTime>();
  final RxnString photoPath = RxnString();
  final RxBool saving = false.obs;
  final RxnString nameError = RxnString();
  final RxnString emailError = RxnString();

  /// Name shown under the avatar (updates after a successful save).
  final RxString displayName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
    final name = user?.fullName ?? user?.displayName ?? 'Vikash Kumar';
    profileName.text = name;
    fullName.text = name;
    email.text = 'vikash+60@braintechnosys.com';
    country.value = (user?.countryCode?.length == 2) ? user!.countryCode! : 'IN';
    displayName.value = name;
  }

  Future<void> changePhoto() async {
    final path = await ImagePickerMatchPhotoPicker().pick();
    if (path != null) photoPath.value = path;
  }

  bool _validate() {
    nameError.value = profileName.text.trim().isEmpty || fullName.text.trim().isEmpty ? 'Please enter the name' : null;
    emailError.value = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim()) ? null : 'Please enter a valid email';
    return nameError.value == null && emailError.value == null;
  }

  Future<void> save() async {
    if (saving.value || !_validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    saving.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    displayName.value = profileName.text.trim();
    saving.value = false;
    AppToast.success('Profile updated successfully');
  }

  @override
  void onClose() {
    profileName.dispose();
    fullName.dispose();
    email.dispose();
    team.dispose();
    position.dispose();
    super.onClose();
  }
}
