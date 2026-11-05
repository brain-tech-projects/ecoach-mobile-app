import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';

/// The 13-step "Match Rating" form. Open with `arguments: MatchEntry` to edit.
class MatchFormController extends GetxController {
  MatchFormController(this._repository, this._picker) {
    final a = Get.arguments;
    if (a is MatchEntry) _editing = a;
  }

  final TrackerRepository _repository;
  final MatchPhotoPicker _picker;
  MatchEntry? _editing;

  static const int total = 13;
  final List<MatchStep> steps = MatchSteps.all;

  final RxInt step = 0.obs;
  final RxBool done = false.obs;
  final RxBool saving = false.obs;

  /// Text of every text / number step, by [MatchStep.key].
  final Map<String, TextEditingController> fields = <String, TextEditingController>{};
  final Rxn<DateTime> date = Rxn<DateTime>();
  final RxnString photoPath = RxnString();

  /// Recomputed after every change so the Next button reacts.
  final RxBool canContinue = false.obs;

  bool get isEditing => _editing != null;

  @override
  void onInit() {
    super.onInit();
    for (final s in steps) {
      if (s.kind == StepKind.text || s.kind == StepKind.number) {
        fields[s.key] = TextEditingController()..addListener(_recompute);
      }
    }
    _fill(_editing);
    _recompute();
  }

  void _fill(MatchEntry? e) {
    void put(String k, Object? v) => fields[k]!.text = v == null ? '' : '$v';
    put('opponent', e?.opponent);
    put('score', e?.score);
    put('passing', e?.passing);
    put('dribbling', e?.dribbling);
    put('shooting', e?.shooting);
    put('defending', e?.defending);
    put('pace', e?.pace);
    put('physicality', e?.physicality);
    put('assists', e?.assists);
    put('goals', e?.goals);
    put('saves', e?.saves);
    date.value = e?.playedOn;
    photoPath.value = e?.photoPath;
  }

  MatchStep get current => steps[step.value];

  bool _valid(MatchStep s) {
    switch (s.kind) {
      case StepKind.text:
        return fields[s.key]!.text.trim().isNotEmpty;
      case StepKind.date:
        return date.value != null;
      case StepKind.number:
        final v = int.tryParse(fields[s.key]!.text.trim());
        return v != null && v >= s.min && v <= s.max;
      case StepKind.photo:
        return true;
    }
  }

  void _recompute() => canContinue.value = _valid(current);

  /// Message under a number field while its value is out of range.
  String? errorFor(MatchStep s) {
    if (s.kind != StepKind.number) return null;
    final t = fields[s.key]!.text.trim();
    if (t.isEmpty || _valid(s)) return null;
    return 'Enter a number from ${s.min} to ${s.max}';
  }

  void setDate(DateTime d) {
    date.value = d;
    _recompute();
  }

  void next() {
    if (!canContinue.value || step.value >= total - 1) return;
    FocusManager.instance.primaryFocus?.unfocus();
    step.value++;
    _recompute();
  }

  void previous() {
    if (step.value == 0) return;
    FocusManager.instance.primaryFocus?.unfocus();
    step.value--;
    _recompute();
  }

  Future<void> pickPhoto() async {
    final path = await _picker.pick();
    if (path != null) photoPath.value = path;
  }

  void removePhoto() => photoPath.value = null;

  MatchEntry _build() {
    int n(String k) => int.parse(fields[k]!.text.trim());
    return MatchEntry(
      id: _editing?.id ?? '',
      opponent: fields['opponent']!.text.trim(),
      playedOn: date.value!,
      score: fields['score']!.text.trim(),
      passing: n('passing'),
      dribbling: n('dribbling'),
      shooting: n('shooting'),
      defending: n('defending'),
      pace: n('pace'),
      physicality: n('physicality'),
      assists: n('assists'),
      goals: n('goals'),
      saves: n('saves'),
      photoUrl: _editing?.photoUrl,
      photoPath: photoPath.value,
    );
  }

  Future<void> finish() async {
    if (saving.value) return;
    // Every required step must be valid (guards against a skipped step).
    for (var i = 0; i < steps.length; i++) {
      if (!_valid(steps[i])) {
        step.value = i;
        _recompute();
        AppToast.error('Please complete this step first');
        return;
      }
    }
    saving.value = true;
    try {
      final res = await _repository.saveMatch(_build());
      if (!res.success) throw Exception(res.message);
      FocusManager.instance.primaryFocus?.unfocus();
      done.value = true;
    } catch (error, stackTrace) {
      AppLogger.error('Save match failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not save your rating. Please try again.');
    } finally {
      saving.value = false;
    }
  }

  /// "Make Another Submission".
  void startOver() {
    _editing = null;
    _fill(null);
    step.value = 0;
    done.value = false;
    _recompute();
  }

  @override
  void onClose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.onClose();
  }
}
