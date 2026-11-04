import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';

class MyProfileController extends GetxController {
  MyProfileController(this._repository);

  final PlayerRepository _repository;

  final RxBool loading = true.obs;
  final RxBool saving = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<PlayerProfile> original = Rxn<PlayerProfile>();

  final TextEditingController profileName = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController club = TextEditingController();
  final TextEditingController favPosition = TextEditingController();
  final TextEditingController favTeam = TextEditingController();

  final RxString country = 'ZW'.obs;
  final RxnInt age = RxnInt();
  final RxList<String> positions = <String>[].obs;
  final RxList<String> levels = <String>[].obs;
  final RxList<String> improve = <String>[].obs;
  final RxnString biggestDifference = RxnString();
  final RxnString frequency = RxnString();
  final Rxn<DateTime> dob = Rxn<DateTime>();

  /// Shown under the field after a failed save.
  final RxnString nameError = RxnString();
  final RxnString emailError = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final p = await _repository.fetchProfile();
      original.value = p;
      profileName.text = p.profileName;
      fullName.text = p.fullName;
      email.text = p.parentEmail;
      club.text = p.club;
      favPosition.text = p.favouritePosition;
      favTeam.text = p.favouriteTeam;
      country.value = p.countryCode;
      age.value = p.age;
      positions.assignAll(p.positions);
      levels.assignAll(p.levels);
      improve.assignAll(p.improve);
      biggestDifference.value = p.biggestDifference;
      frequency.value = p.frequency;
      dob.value = p.dateOfBirth;
    } catch (error, stackTrace) {
      AppLogger.error('Profile load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your profile.';
    } finally {
      loading.value = false;
    }
  }

  void onChangePhoto() => AppToast.info('Photo upload coming soon');

  bool _validate() {
    nameError.value = profileName.text.trim().isEmpty || fullName.text.trim().isEmpty
        ? 'Please enter the name'
        : null;
    final mail = email.text.trim();
    emailError.value = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail)
        ? null
        : 'Please enter a valid email';
    return nameError.value == null && emailError.value == null;
  }

  Future<void> save() async {
    if (saving.value || !_validate()) {
      if (nameError.value != null || emailError.value != null) {
        AppToast.error(nameError.value ?? emailError.value!);
      }
      return;
    }
    final base = original.value!;
    final updated = PlayerProfile(
      profileName: profileName.text.trim(),
      fullName: fullName.text.trim(),
      parentEmail: email.text.trim(),
      countryCode: country.value,
      club: club.text.trim(),
      favouritePosition: favPosition.text.trim(),
      favouriteTeam: favTeam.text.trim(),
      age: age.value,
      positions: List<String>.of(positions),
      levels: List<String>.of(levels),
      improve: List<String>.of(improve),
      biggestDifference: biggestDifference.value,
      frequency: frequency.value,
      dateOfBirth: dob.value,
      photoAsset: base.photoAsset,
      photoUrl: base.photoUrl,
    );
    saving.value = true;
    try {
      await _repository.updateProfile(updated);
      original.value = updated;
      AppToast.success('Profile updated successfully');
    } catch (error, stackTrace) {
      AppLogger.error('Profile update failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not update your profile. Please try again.');
    } finally {
      saving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in <TextEditingController>[
      profileName, fullName, email, club, favPosition, favTeam,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
