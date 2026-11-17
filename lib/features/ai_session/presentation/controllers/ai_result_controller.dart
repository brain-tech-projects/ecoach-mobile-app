import 'dart:async';

import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_home_controller.dart';

/// "Here's your session": types the summary word by word.
/// Route arguments: [AiSession].
class AiResultController extends GetxController {
  final AiSession session = Get.arguments as AiSession;
  final String firstName = aiFirstName();

  late final List<String> words = session.summary.split(' ');
  final RxInt shown = 0.obs;
  Timer? _timer;

  bool get typingDone => shown.value >= words.length;

  @override
  void onReady() {
    super.onReady();
    _timer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      if (shown.value >= words.length) {
        t.cancel();
        return;
      }
      shown.value++;
    });
  }

  void openDrill(int index) => Get.toNamed<void>(AppRoutes.aiPlayer, arguments: AiPlayerArgs(session, index));
  void start() => openDrill(0);

  /// Back to the first screen with the request pre-filled (or cleared).
  void backToHome({required bool keepRequest}) {
    Get.until((r) => r.settings.name == AppRoutes.aiSession || r.isFirst);
    if (Get.isRegistered<AiHomeController>()) {
      Get.find<AiHomeController>().prefill(keepRequest ? session.request : '');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class AiPlayerArgs {
  const AiPlayerArgs(this.session, this.index);
  final AiSession session;
  final int index;
}
