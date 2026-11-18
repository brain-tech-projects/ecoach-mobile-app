import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';

/// First AI screen: choose what to improve, then create / reopen sessions.
class AiHomeController extends GetxController {
  static const int maxLength = 200;
  static const int collapsedCount = 3;

  final TextEditingController input = TextEditingController();
  final FocusNode focus = FocusNode();
  final RxnString selectedChip = RxnString();
  final RxInt count = 0.obs;
  final RxBool canCreate = false.obs;
  final RxList<AiSessionSummary> recent = <AiSessionSummary>[].obs;
  final RxBool expanded = false.obs;
  final RxBool loading = true.obs;
  final RxnInt openingId = RxnInt();

  final String firstName = aiFirstName();

  AiSessionRepository get _repo => Get.find<AiSessionRepository>();

  List<AiSessionSummary> get visibleRecent => expanded.value ? recent.toList() : recent.take(collapsedCount).toList();
  int get hiddenCount => recent.length - collapsedCount;

  @override
  void onInit() {
    super.onInit();
    ensureAiSessionRepository();
    input.addListener(_onText);
  }

  @override
  void onReady() {
    super.onReady();
    loadRecent();
  }

  void _onText() {
    final text = input.text;
    count.value = text.length;
    canCreate.value = text.trim().isNotEmpty;
    final chip = selectedChip.value;
    if (chip != null) {
      final match = AiSessionRepository.chips.firstWhere((c) => c.label == chip);
      if (match.prompt != text) selectedChip.value = null;
    }
  }

  Future<void> loadRecent() async {
    try {
      recent.assignAll(await _repo.fetchRecent());
    } catch (e, st) {
      AppLogger.error('AI recent failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  void _setText(String text) {
    input.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  void selectChip(AiChip chip) {
    if (selectedChip.value == chip.label) {
      _setText('');
      selectedChip.value = null;
      return;
    }
    _setText(chip.prompt);
    selectedChip.value = chip.label;
  }

  void useSuggestion(String text) => _setText(text);

  /// Used by "Edit request" / "New session" on the result screen.
  void prefill(String text) {
    _setText(text);
    focus.requestFocus();
  }

  void toggleMore() => expanded.toggle();

  Future<void> create() async {
    if (!canCreate.value) return;
    focus.unfocus();
    await _build(input.text.trim());
  }

  Future<void> newVersion(AiSessionSummary s) => _build(s.request);

  Future<void> _build(String request) async {
    await Get.toNamed<void>(AppRoutes.aiBuilding, arguments: request);
    loadRecent();
  }

  /// Opens a recent session (its drills come from `/ai/session-detail`).
  Future<void> open(AiSessionSummary s) async {
    if (openingId.value != null) return;
    openingId.value = s.id;
    AiSession? session;
    try {
      session = await _repo.fetchSession(s);
    } catch (e, st) {
      AppLogger.error('AI session open failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not open this session. Please try again.');
    } finally {
      openingId.value = null;
    }
    if (session != null) await Get.toNamed<void>(AppRoutes.aiResult, arguments: session);
  }

  @override
  void onClose() {
    input.dispose();
    focus.dispose();
    super.onClose();
  }
}
