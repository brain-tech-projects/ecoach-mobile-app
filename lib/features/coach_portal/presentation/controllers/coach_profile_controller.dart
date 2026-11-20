import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/auth/data/models/user_model.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/tracker/data/repositories/image_picker_photo_picker.dart';

/// Coach My Profile: GET /profile, POST /update-profile.
class CoachProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final TextEditingController profileName = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController team = TextEditingController();
  final TextEditingController position = TextEditingController();

  final RxString country = 'IN'.obs;
  final Rxn<DateTime> dob = Rxn<DateTime>();
  final RxnString photoPath = RxnString(); // newly picked local file
  final RxnString photoUrl = RxnString(); // photo already on the server
  final RxBool saving = false.obs;
  final RxBool loading = false.obs;
  final RxnString nameError = RxnString();
  final RxnString emailError = RxnString();

  /// Name shown under the avatar (updates after a successful save).
  final RxString displayName = ''.obs;

  Map<String, dynamic> _profile = <String, dynamic>{};

  @override
  void onInit() {
    super.onInit();
    // Show the session data straight away, the API fills in the rest.
    final user = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
    final name = user?.fullName ?? user?.displayName ?? '';
    profileName.text = user?.nickname ?? name;
    fullName.text = name;
    email.text = user?.email ?? '';
    country.value = (user?.countryCode?.length == 2) ? user!.countryCode! : 'IN';
    displayName.value = name;
    photoUrl.value = user?.profilePhoto;
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final res = requireSuccess(await _api.getProfile());
      final d = res.data;
      if (d is! Map) return;
      final j = _profile = Map<String, dynamic>.from(d);
      profileName.text = (j['nickname'] ?? '').toString();
      fullName.text = (j['full_name'] ?? '').toString();
      email.text = (j['email'] ?? '').toString();
      team.text = (j['my_club'] ?? '').toString();
      position.text = (j['my_position'] ?? '').toString();
      final code = (j['country_code'] ?? '').toString();
      if (code.length == 2 || code.startsWith('GB-')) country.value = code;
      dob.value = DateTime.tryParse('${j['dob'] ?? ''}');
      photoUrl.value = Env.skillMediaUrl(j['profile_photo'] as String?);
      displayName.value = fullName.text;
    } catch (e, st) {
      AppLogger.error('Coach profile load failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not load your profile.');
    } finally {
      loading.value = false;
    }
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

    String two(int v) => v.toString().padLeft(2, '0');
    final d = dob.value;
    UserModel? updated;
    final ok = await coachRun(() async {
      final res = requireSuccess(
        await _api.updateCoachProfile(
          fields: <String, dynamic>{
            'id': _profile['id'] ?? Get.find<SessionService>().user.value?.id,
            'nickname': profileName.text.trim(),
            'full_name': fullName.text.trim(),
            'email': email.text.trim(),
            'role': _profile['role'] ?? 'Coach',
            'my_club': team.text.trim(),
            'my_position': position.text.trim(),
            if (d != null) 'dob': '${d.year}-${two(d.month)}-${two(d.day)}',
            'country': ProfileOptions.countries[country.value] ?? _profile['country'] ?? '',
            'country_code': country.value,
          },
          photoPath: photoPath.value,
        ),
      );
      final data = res.data;
      if (data is Map) updated = UserModel.fromJson(Map<String, dynamic>.from(data));
    }, success: 'Profile updated successfully');
    saving.value = false;
    if (!ok) return;

    displayName.value = fullName.text.trim();
    final u = updated;
    if (u != null) {
      // Keep the header / menu name and photo up to date.
      await Get.find<SessionService>().updateUser(u);
      photoUrl.value = u.profilePhoto ?? photoUrl.value;
      photoPath.value = null;
    }
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
