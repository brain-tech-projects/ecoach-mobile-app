import 'package:flutter/painting.dart' show Color;
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';
import 'package:ecoach_pro/features/stats/presentation/widgets/redeem_dialog.dart';

/// One trophy + the "Redeem" flow. Open with `arguments: Trophy`.
class TrophyDetailController extends GetxController {
  TrophyDetailController(this._repository);

  final TrophyRepository _repository;
  final Trophy trophy = Get.arguments as Trophy;

  Future<void> onRedeemTap() async {
    await Get.dialog<void>(
      RedeemDialog(onRedeem: _redeem),
      barrierColor: const Color(0xB3000000),
    );
  }

  /// true = redeemed (dialog closes). false = error toast, dialog stays.
  Future<bool> _redeem() async {
    try {
      final result = await _repository.redeem(trophy);
      if (result.success) {
        AppToast.success(result.message);
        return true;
      }
      AppToast.error(result.message);
      return false;
    } catch (error, stackTrace) {
      AppLogger.error('Redeem failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not redeem the trophy. Please try again.');
      return false;
    }
  }
}
