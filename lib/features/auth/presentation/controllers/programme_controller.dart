import 'dart:async';

import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/auth/domain/entities/programme_summary.dart';

enum ProgrammePhase { generating, ready }

/// After sign-up: fake "generating" progress -> summary -> "Unlock My
/// Programme" (signs in, then opens Subscription on top of the dashboard).
class ProgrammeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  late final ProgrammeArgs args = Get.arguments as ProgrammeArgs;

  static const List<String> stepLabels = <String>[
    'Analysing player profile',
    'Selecting position-specific drills',
    'Choosing skills to improve',
    'Building your training plan',
  ];

  final Rx<ProgrammePhase> phase = ProgrammePhase.generating.obs;
  final RxInt completedSteps = 0.obs;
  final RxBool unlocking = false.obs;

  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (t) {
      completedSteps.value++;
      if (completedSteps.value >= stepLabels.length) {
        t.cancel();
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!isClosed) phase.value = ProgrammePhase.ready;
        });
      }
    });
  }

  Future<void> unlock() async {
    if (unlocking.value) return;
    unlocking.value = true;
    try {
      final res = await _api.login(email: args.email, password: args.password);
      if (!res.success) {
        AppToast.error(res.message);
        Get.offAllNamed<void>(AppRoutes.signIn);
        return;
      }
      AppToast.success('User Logged in Successfully.');
      Get.offAllNamed<void>(AppRoutes.dashboard);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      Get.toNamed<void>(AppRoutes.subscription);
    } finally {
      if (!isClosed) unlocking.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
