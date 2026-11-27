import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/push_service.dart';
import 'package:ecoach_pro/core/services/realtime_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/coach_action.dart';

/// Chats: player list -> conversation (same page, back arrow returns to list).
class ChatsController extends GetxController with WidgetsBindingObserver {
  final RxList<CoachPlayer> players = <CoachPlayer>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rxn<CoachPlayer> selected = Rxn<CoachPlayer>();
  final RxBool loading = true.obs;
  final RxBool loadingMessages = false.obs;
  final RxBool canSend = false.obs;

  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  CoachPortalRepository get _repo => Get.find<CoachPortalRepository>();

  static const Duration _pollEvery = Duration(seconds: 5);
  Timer? _poll;
  StreamSubscription<Map<String, dynamic>>? _push;
  StreamSubscription<void>? _live;
  DateTime _lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  bool _fetching = false;
  bool _sending = false;

  @override
  void onInit() {
    super.onInit();
    input.addListener(() => canSend.value = input.text.trim().isNotEmpty);
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(_pollEvery, (_) {
      final live = Get.isRegistered<RealtimeService>() && Get.find<RealtimeService>().connected.value;
      if (live && DateTime.now().difference(_lastRefresh) < const Duration(seconds: 30)) return;
      _refreshOpen();
    });
    if (Get.isRegistered<RealtimeService>()) {
      _live = Get.find<RealtimeService>().chatChanged.listen((_) => _refreshOpen());
    }
    if (Get.isRegistered<PushService>()) {
      final push = Get.find<PushService>();
      _push = push.messages.listen((_) => _refreshOpen());
      // The open conversation shows the message itself: no banner for it.
      push.suppressBanner = (data) {
        final open = selected.value;
        if (open == null) return false;
        final from = '${data['sender_id'] ?? data['from_id'] ?? data['user_id'] ?? ''}';
        return from.isEmpty || from == '${open.id}';
      };
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    loading.value = true;
    try {
      // Only connected players can be messaged.
      players.assignAll(await _repo.fetchConnectedPlayers());
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
    messages.clear();
    input.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshOpen();
      _poll?.cancel();
      _poll = Timer.periodic(_pollEvery, (_) => _refreshOpen());
    } else {
      _poll?.cancel();
    }
  }

  /// Quiet re-check of the open conversation (new messages, "Seen").
  Future<void> _refreshOpen() async {
    final p = selected.value;
    if (p == null || _fetching || _sending || loadingMessages.value) return;
    _fetching = true;
    _lastRefresh = DateTime.now();
    try {
      final fresh = await _repo.fetchMessages(p.id);
      if (selected.value?.id != p.id) return; // user switched chats meanwhile
      final changed = fresh.length != messages.length ||
          (fresh.isNotEmpty && messages.isNotEmpty && (fresh.last.id != messages.last.id || fresh.last.seen != messages.last.seen));
      if (!changed) return;
      final near = !scroll.hasClients || scroll.position.maxScrollExtent - scroll.position.pixels < 120;
      final grew = fresh.length > messages.length;
      messages.assignAll(fresh);
      if (grew && near) _toBottom();
    } catch (e, st) {
      AppLogger.error('Chat refresh failed', error: e, stackTrace: st);
    } finally {
      _fetching = false;
    }
  }

  Future<void> send() async {
    final p = selected.value;
    final text = input.text.trim();
    if (p == null || text.isEmpty || _sending) return;
    _sending = true;
    input.clear();
    final ok = await coachRun(() async {
      final sent = await _repo.sendMessage(p.id, text);
      if (selected.value?.id == p.id && !messages.any((m) => m.id == sent.id)) messages.add(sent);
    });
    _sending = false;
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
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    _push?.cancel();
    _live?.cancel();
    if (Get.isRegistered<PushService>()) Get.find<PushService>().suppressBanner = null;
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
