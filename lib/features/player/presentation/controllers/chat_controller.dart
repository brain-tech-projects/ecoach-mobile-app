import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/push_service.dart';
import 'package:ecoach_pro/core/services/realtime_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';

/// One conversation. Open with `arguments: Coach`.
///
/// Real-time feel without a socket: a push notification refreshes the chat at
/// once, and while the screen is open (app in front) it also re-checks every
/// few seconds. Messages you send appear immediately ("Sending...") and can be
/// retried if the network fails.
class ChatController extends GetxController with WidgetsBindingObserver {
  ChatController(this._repository);

  final PlayerRepository _repository;
  final Coach coach = Get.arguments as Coach;

  static const Duration _pollEvery = Duration(seconds: 5);

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool loading = true.obs;

  /// Kept for the send button; sending is instant, so this stays false.
  final RxBool sending = false.obs;
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  Timer? _poll;
  StreamSubscription<Map<String, dynamic>>? _push;
  StreamSubscription<void>? _live;
  DateTime _lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  bool _fetching = false;
  int _localSeq = 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<RealtimeService>()) {
      _live = Get.find<RealtimeService>().chatChanged.listen((_) => refresh());
    }
    if (Get.isRegistered<PushService>()) {
      final push = Get.find<PushService>();
      _push = push.messages.listen((_) => refresh());
      // The open chat shows the message itself: no banner for it.
      push.suppressBanner = (data) {
        final from = '${data['sender_id'] ?? data['from_id'] ?? data['user_id'] ?? ''}';
        return from.isEmpty || from == coach.id;
      };
    }
  }

  @override
  void onReady() {
    super.onReady();
    load();
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      _startPolling();
    } else {
      _poll?.cancel();
    }
  }

  void _startPolling() {
    _poll?.cancel();
    // With the live connection up, polling is only a safety net.
    _poll = Timer.periodic(_pollEvery, (_) {
      final live = Get.isRegistered<RealtimeService>() && Get.find<RealtimeService>().connected.value;
      if (live && DateTime.now().difference(_lastRefresh) < const Duration(seconds: 30)) return;
      refresh();
    });
  }

  Future<void> load() async {
    loading.value = true;
    try {
      _merge(await _repository.fetchMessages(coach.id), forceScroll: true);
    } catch (error, stackTrace) {
      AppLogger.error('Messages load failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not load messages.');
    } finally {
      loading.value = false;
      _toBottom(jump: true);
    }
  }

  /// Quiet re-check (no spinner, errors ignored): new messages, "Seen" ticks.
  Future<void> refresh() async {
    if (_fetching || loading.value) return;
    _fetching = true;
    _lastRefresh = DateTime.now();
    try {
      _merge(await _repository.fetchMessages(coach.id));
    } catch (error, stackTrace) {
      AppLogger.error('Messages refresh failed', error: error, stackTrace: stackTrace);
    } finally {
      _fetching = false;
    }
  }

  /// Server list + messages still waiting to be sent from this phone.
  void _merge(List<ChatMessage> server, {bool forceScroll = false}) {
    final local = messages.where((m) => m.isLocal).toList();
    final current = messages.where((m) => !m.isLocal).toList();
    final unchanged = current.length == server.length &&
        <int>[for (var i = 0; i < server.length; i++) i]
            .every((i) => current[i].id == server[i].id && current[i].status == server[i].status);
    if (unchanged && !forceScroll) return;

    final wasNearBottom = _nearBottom();
    final grew = server.length > current.length;
    messages.assignAll(<ChatMessage>[...server, ...local]);
    if (forceScroll || (grew && wasNearBottom)) _toBottom();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    final temp = ChatMessage(
      id: 'local-${++_localSeq}',
      text: text,
      sentAt: DateTime.now(),
      mine: true,
      status: MessageStatus.sending,
    );
    messages.add(temp);
    _toBottom();
    await _deliver(temp);
  }

  void retry(ChatMessage m) {
    if (m.status != MessageStatus.failed) return;
    _deliver(m);
  }

  Future<void> _deliver(ChatMessage temp) async {
    _swap(temp.id, temp.copyWith(status: MessageStatus.sending));
    try {
      final sent = await _repository.sendMessage(coach.id, temp.text);
      final i = messages.indexWhere((m) => m.id == temp.id);
      if (i == -1) return;
      if (messages.any((m) => m.id == sent.id)) {
        messages.removeAt(i); // the refresh already brought it in
      } else {
        messages[i] = sent;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Send failed', error: error, stackTrace: stackTrace);
      _swap(temp.id, temp.copyWith(status: MessageStatus.failed));
      AppToast.error('Message not sent. Tap it to try again.');
    }
  }

  void _swap(String id, ChatMessage next) {
    final i = messages.indexWhere((m) => m.id == id);
    if (i != -1) messages[i] = next;
  }

  bool _nearBottom() {
    if (!scroll.hasClients) return true;
    return scroll.position.maxScrollExtent - scroll.position.pixels < 120;
  }

  void _toBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      final end = scroll.position.maxScrollExtent;
      if (jump) {
        scroll.jumpTo(end);
      } else {
        scroll.animateTo(end, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
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
