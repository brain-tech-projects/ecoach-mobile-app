import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';

/// One conversation. Open with `arguments: Coach`.
class ChatController extends GetxController {
  ChatController(this._repository);

  final PlayerRepository _repository;
  final Coach coach = Get.arguments as Coach;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool loading = true.obs;
  final RxBool sending = false.obs;
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      messages.assignAll(await _repository.fetchMessages(coach.id));
    } catch (error, stackTrace) {
      AppLogger.error('Messages load failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not load messages.');
    } finally {
      loading.value = false;
      _toBottom(jump: true);
    }
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending.value) return;
    sending.value = true;
    try {
      final m = await _repository.sendMessage(coach.id, text);
      messages.add(m);
      input.clear();
      _toBottom();
    } catch (error, stackTrace) {
      AppLogger.error('Send failed', error: error, stackTrace: stackTrace);
      AppToast.error('Message not sent. Please try again.');
    } finally {
      sending.value = false;
    }
  }

  void _toBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      final end = scroll.position.maxScrollExtent;
      if (jump) {
        scroll.jumpTo(end);
      } else {
        scroll.animateTo(end,
            duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  @override
  void onClose() {
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
