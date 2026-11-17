import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';

enum TrainingSource { ecoach, own }

/// Add New Training / Update Training (arguments: TrainingProgram to edit):
/// 0 choose source -> 1 form -> 2 submitted.
class AddTrainingController extends GetxController {
  static const int _maxVideoBytes = 500 * 1024 * 1024;

  final TrainingProgram? editing = Get.arguments is TrainingProgram ? Get.arguments as TrainingProgram : null;
  bool get isEdit => editing != null;

  /// Video already stored on an "own" program (shown until a new one is picked).
  String? get existingOwnVideo => (editing?.isOwn ?? false) && editing!.videoPath.isNotEmpty ? editing!.videoPath : null;

  final RxInt step = 0.obs;
  final Rxn<TrainingSource> source = Rxn<TrainingSource>();

  // eCoach video
  final RxList<SkillItem> categories = <SkillItem>[].obs;
  final RxList<DrillItem> drills = <DrillItem>[].obs;
  final Rxn<SkillItem> category = Rxn<SkillItem>();
  final Rxn<DrillItem> drill = Rxn<DrillItem>();
  final RxBool loadingCategories = false.obs;
  final RxBool loadingDrills = false.obs;
  final RxBool loadingVideo = false.obs;

  // Own video
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final RxnString videoPath = RxnString();
  final RxDouble progress = 0.0.obs;

  final RxBool submitting = false.obs;

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  bool get isEcoach => source.value == TrainingSource.ecoach;
  bool get canSubmit => isEcoach ? (drill.value?.videoUrl.isNotEmpty ?? false) && !loadingVideo.value : (videoPath.value != null || existingOwnVideo != null);

  @override
  void onInit() {
    super.onInit();
    title.addListener(() => videoPath.refresh());
    final p = editing;
    if (p != null) {
      // Pre-select what the program uses now.
      source.value = p.isOwn ? TrainingSource.own : TrainingSource.ecoach;
      if (p.isOwn) {
        title.text = p.title;
        description.text = p.description;
      }
    }
  }

  void choose(TrainingSource value) => source.value = value;

  Future<void> next() async {
    if (source.value == null) return;
    step.value = 1;
    if (isEcoach) {
      if (categories.isEmpty) await _loadCategories();
      await _prefillEcoach();
    }
  }

  /// Update Training: select the skill and video the program already has.
  Future<void> _prefillEcoach() async {
    final p = editing;
    if (p == null || !p.isEcoach || category.value != null || p.skillTypeId == null) return;
    final match = categories.firstWhereOrNull((c) => c.id == p.skillTypeId);
    if (match == null) return;
    await selectCategory(match);
    final d = drills.firstWhereOrNull((e) => e.id == p.skillVideoId);
    if (d != null) drill.value = d;
  }

  void previous() => step.value = 0;

  void cancel() => Get.back<void>();

  Future<void> _loadCategories() async {
    loadingCategories.value = true;
    try {
      categories.assignAll(await _repo.fetchSkillCategories());
    } catch (e, st) {
      AppLogger.error('Skill categories failed', error: e, stackTrace: st);
      AppToast.error('Could not load skills.');
    } finally {
      loadingCategories.value = false;
    }
  }

  Future<void> selectCategory(SkillItem picked) async {
    if (picked.id == category.value?.id) return;
    category.value = picked;
    drill.value = null;
    drills.clear();
    loadingDrills.value = true;
    try {
      final list = await _repo.fetchSkillDrills(picked.id);
      // Ignore a late answer if another skill was picked meanwhile.
      if (category.value?.id == picked.id) drills.assignAll(list);
    } catch (e, st) {
      AppLogger.error('Skill videos failed', error: e, stackTrace: st);
      AppToast.error('Could not load the training videos.');
    } finally {
      loadingDrills.value = false;
    }
  }

  void selectDrill(DrillItem picked) => drill.value = picked;

  Future<void> pickVideo() async {
    try {
      final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      if (!file.path.toLowerCase().endsWith('.mp4')) {
        AppToast.error('Only .mp4 videos are supported');
        return;
      }
      if (await File(file.path).length() > _maxVideoBytes) {
        AppToast.error('The video is too large (max 500MB)');
        return;
      }
      videoPath.value = file.path;
    } on PlatformException catch (e, st) {
      AppLogger.error('Video pick failed', error: e, stackTrace: st);
      AppToast.error(e.code.contains('denied') ? 'Permission denied. Please allow photo access in Settings.' : 'Could not get the video. Please try again.');
    }
  }

  Future<void> submit() async {
    if (submitting.value || !canSubmit) return;
    FocusManager.instance.primaryFocus?.unfocus();
    progress.value = 0;
    submitting.value = true;
    final edit = editing;
    final ownTitle = title.text.trim().isEmpty ? (videoPath.value?.split('/').last ?? edit?.title ?? '') : title.text.trim();
    final ok = await coachRun(() {
      if (edit != null) {
        return isEcoach
            ? _repo.updateEcoachProgram(edit, category.value!, drill.value!)
            : _repo.updateOwnProgram(edit, title: ownTitle, description: description.text.trim(), newVideoPath: videoPath.value, onProgress: (v) => progress.value = v);
      }
      return isEcoach
          ? _repo.createEcoachProgram(category.value!, drill.value!)
          : _repo.createOwnProgram(title: ownTitle, description: description.text.trim(), videoPath: videoPath.value!, onProgress: (v) => progress.value = v);
    });
    submitting.value = false;
    if (ok) step.value = 2;
  }

  /// "See All Training Programs": back to the list (or open it when we came from Home).
  void seeAll() {
    if (Get.previousRoute == AppRoutes.coachPrograms) {
      Get.back<void>();
    } else {
      Get.offNamed<void>(AppRoutes.coachPrograms);
    }
  }

  /// "Done".
  void finish() => Get.until((route) => route.settings.name == AppRoutes.coachPrograms || route.settings.name == AppRoutes.dashboard || route.isFirst);

  @override
  void onClose() {
    title.dispose();
    description.dispose();
    super.onClose();
  }
}
