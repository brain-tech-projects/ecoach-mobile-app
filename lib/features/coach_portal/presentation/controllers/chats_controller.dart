import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';

/// Chats: player list -> conversation (same page, back arrow returns to list).
class ChatsController extends GetxController {
  final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rxn<CoachPlayer> selected = Rxn<CoachPlayer>();
  final RxBool loading = true.obs;
  final RxBool loadingMessages = false.obs;
  final RxBool canSend = false.obs;

  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  @override
  void onInit() {
    super.onInit();
    input.addListener(() => canSend.value = input.text.trim().isNotEmpty);
  }

  @override
  void onReady() {
    super.onReady();
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    loading.value = true;
    try {
      players.assignAll(await _repo.fetchPlayers());
    } catch (e, st) {
      AppLogger.error('Chat players failed', error: e, stackTrace: st);
    } finally {
      loading.value = false;
    }
  }

  Future<void> open(CoachPlayer p) async {
    selected.value = p;
    messages.clear();
    loadingMessages.value = true;
    try {
      messages.assignAll(await _repo.fetchMessages(p.id));
    } catch (e, st) {
      AppLogger.error('Chat messages failed', error: e, stackTrace: st);
      AppToast.error(e is ApiException ? e.message : 'Could not load the messages.');
    } finally {
      loadingMessages.value = false;
    }
    _toBottom();
  }

  void close() {
    selected.value = null;
    input.clear();
  }

  Future<void> send() async {
    final p = selected.value;
    final text = input.text.trim();
    if (p == null || text.isEmpty) return;
    input.clear();
    final ok = await coachRun(() async => messages.add(await _repo.sendMessage(p.id, text)));
    if (ok) {
      _toBottom();
    } else {
      input.text = text; // keep the text so it can be sent again
    }
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  @override
  void onClose() {
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
