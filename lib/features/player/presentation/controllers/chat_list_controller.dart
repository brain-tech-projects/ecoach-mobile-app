import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';

/// Chats: the list of conversations (currently only the connected coach).
class ChatListController extends GetxController {
  ChatListController(this._coaches);

  final CoachRepository _coaches;
  final Rxn<Coach> coach = Rxn<Coach>();
  final RxBool loading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    errorMessage.value = null;
    try {
      coach.value = await _coaches.fetchConnectedCoach();
    } catch (error, stackTrace) {
      AppLogger.error('Chat list load failed', error: error, stackTrace: stackTrace);
      errorMessage.value = 'Could not load your chats.';
    } finally {
      loading.value = false;
    }
  }

  void open(Coach c) => Get.toNamed<void>(AppRoutes.chat, arguments: c);
}
