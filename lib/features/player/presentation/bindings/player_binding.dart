import 'package:get/get.dart';

import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';
import 'package:ecoach_pro/features/fun/domain/repositories/fun_repository.dart';
import 'package:ecoach_pro/features/fun/presentation/bindings/fun_binding.dart';
import 'package:ecoach_pro/features/coach/presentation/bindings/coach_binding.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/player/data/repositories/api_player_repository.dart';
import 'package:ecoach_pro/features/player/domain/repositories/player_repository.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/chat_controller.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/chat_list_controller.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/my_profile_controller.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/my_skills_controller.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/notes_controller.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/notifications_controller.dart';

/// One shared repository (keeps removals / notes / messages between pages).
/// Backed by the API (`ApiPlayerRepository`).
void ensurePlayerRepository() {
  if (!Get.isRegistered<PlayerRepository>()) {
    Get.put<PlayerRepository>(
      ApiPlayerRepository(Get.find<ApiService>(), Get.find<SessionService>()),
      permanent: true,
    );
  }
  ensureCoachRepository();
}

PlayerRepository get _repo => Get.find<PlayerRepository>();

/// Registers FunRepository through YOUR ChallengesBinding, so swapping
/// Dummy -> Api in fun_binding.dart also applies here.
FunRepository get _fun {
  ChallengesBinding().dependencies();
  return Get.find<FunRepository>();
}

class MyProfileBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<MyProfileController>(() => MyProfileController(_repo));
  }
}

class MySkillsBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<MySkillsController>(() => MySkillsController(_repo, _fun));
  }
}

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<NotesController>(() => NotesController(_repo, _fun));
  }
}

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<ChatListController>(
      () => ChatListController(Get.find<CoachRepository>()),
    );
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<ChatController>(() => ChatController(_repo));
  }
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    ensurePlayerRepository();
    Get.lazyPut<NotificationsController>(() => NotificationsController(_repo));
  }
}
