import 'package:get/get.dart';

import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/add_training_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/chats_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/invitations_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/summary_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/player_detail_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/players_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/programs_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/team_form_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/teams_controller.dart';

class TeamsBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<TeamsController>(TeamsController.new);
  }
}

class TeamFormBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<TeamFormController>(TeamFormController.new);
  }
}

class PlayersBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<PlayersController>(PlayersController.new);
  }
}

class PlayerDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<PlayerDetailController>(PlayerDetailController.new);
  }
}

class ProgramsBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<ProgramsController>(ProgramsController.new);
  }
}

class AddTrainingBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<AddTrainingController>(AddTrainingController.new);
  }
}

class ChatsBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<ChatsController>(ChatsController.new);
  }
}

class SummaryBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<SummaryController>(SummaryController.new);
  }
}

class InvitationsBinding extends Bindings {
  @override
  void dependencies() {
    ensureCoachPortalRepository();
    Get.lazyPut<InvitationsController>(InvitationsController.new);
  }
}
