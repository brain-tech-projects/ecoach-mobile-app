import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

/// The "⋮" menu actions, shared by the drill list and the drill page.
/// Each returns the updated drill, or null when nothing changed.
abstract final class DrillActions {
  static Future<Drill?> toggleSession(SkillsRepository repo, Drill drill) async {
    final add = drill.canAddToSession;
    final res = await repo.setInPersonalSession(drill.id, add: add);
    if (res.isSubscriptionRequired) {
      Get.toNamed<void>(AppRoutes.subscription);
      return null;
    }
    if (!res.success) {
      AppToast.error(res.message);
      return null;
    }
    AppToast.success(res.message);
    return drill.copyWith(canAddToSession: !add);
  }

  static Future<Drill?> toggleMySkills(SkillsRepository repo, Drill drill) async {
    final add = drill.canAddToMySkills;
    final res = await repo.setInMySkills(drill.id, add: add);
    if (res.isSubscriptionRequired) {
      Get.toNamed<void>(AppRoutes.subscription);
      return null;
    }
    if (!res.success) {
      AppToast.error(res.message);
      return null;
    }
    AppToast.success(res.message);
    return drill.copyWith(canAddToMySkills: !add);
  }
}
