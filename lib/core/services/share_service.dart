import 'package:flutter/painting.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

/// Thin wrapper over `share_plus` (needs `flutter pub add share_plus`).
abstract final class ShareService {
  /// [origin] is required on iPad (popover anchor); harmless elsewhere.
  static Future<void> shareText(String text, {Rect? origin}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: origin),
      );
    } catch (e, st) {
      AppLogger.error('Share failed', error: e, stackTrace: st);
      AppToast.error('Could not open the share sheet.');
    }
  }
}
