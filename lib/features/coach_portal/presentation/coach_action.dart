import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

/// Runs a repository call, toasts [success] or the server error. true = worked.
Future<bool> coachRun(
  Future<void> Function() action, {
  String? success,
  String fallback = 'Something went wrong. Please try again.',
}) async {
  try {
    await action();
    if (success != null) AppToast.success(success);
    return true;
  } on ApiException catch (e) {
    AppToast.error(e.message);
  } catch (e, st) {
    AppLogger.error('Coach action failed', error: e, stackTrace: st);
    AppToast.error(fallback);
  }
  return false;
}
