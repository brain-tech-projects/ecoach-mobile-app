import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/skills/presentation/widgets/complete_dialog.dart';

/// One row of "Transaction History".
class PlanEntry {
  const PlanEntry({
    required this.plan,
    required this.amount,
    required this.status,
    required this.startsAt,
    this.endsAt,
  });

  final String plan;
  final String amount;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;
}

class AppSettingsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  static const String terms = 'terms';
  static const String password = 'password';
  static const String history = 'history';

  /// Which accordion is open (null = all closed).
  final RxnString open = RxnString();

  void toggle(String id) {
    open.value = open.value == id ? null : id;
    if (open.value == history && !_historyLoaded) loadHistory();
  }

  // ---- Change password --------------------------------------------------------

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool savingPassword = false.obs;

  Future<void> changePassword() async {
    if (savingPassword.value) return;
    final old = currentController.text;
    final next = newController.text;
    final again = confirmController.text;

    if (old.isEmpty || next.isEmpty || again.isEmpty) {
      AppToast.error('Please fill in all the password fields.');
      return;
    }
    if (next.length < 8) {
      AppToast.error('The new password must be at least 8 characters.');
      return;
    }
    if (next != again) {
      AppToast.error('The password confirmation does not match.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    savingPassword.value = true;
    try {
      final res = await _api.changePassword(
        oldPassword: old,
        newPassword: next,
        confirmation: again,
      );
      if (!res.success) {
        AppToast.error(res.message);
        return;
      }
      AppToast.success(res.message);
      currentController.clear();
      newController.clear();
      confirmController.clear();
      open.value = null;
    } finally {
      savingPassword.value = false;
    }
  }

  // ---- Transaction history ----------------------------------------------------

  final RxList<PlanEntry> plans = <PlanEntry>[].obs;
  final RxBool historyLoading = false.obs;
  final RxnString historyError = RxnString();
  bool _historyLoaded = false;

  static DateTime? _date(Object? v) => DateTime.tryParse('${v ?? ''}')?.toLocal();

  static String _title(String v) =>
      v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);

  Future<void> loadHistory() async {
    historyLoading.value = true;
    historyError.value = null;
    try {
      final res = await _api.getPlanHistory();
      if (res.isSubscriptionRequired) {
        Get.toNamed<void>(AppRoutes.subscription);
        return;
      }
      final data = res.data;
      if (data is List) {
        plans.assignAll(<PlanEntry>[
          for (final e in data.whereType<Map>())
            PlanEntry(
              plan: _title('${e['plan'] ?? ''}'),
              amount: '${e['symbol'] ?? ''} ${e['amount_charged'] ?? e['amount'] ?? ''}'.trim(),
              status: '${e['status_label'] ?? _title('${e['status'] ?? ''}')}',
              startsAt: _date(e['starts_at']),
              endsAt: _date(e['ends_at']),
            ),
        ]);
        _historyLoaded = true;
      } else if (res.message.toLowerCase().contains('no plan')) {
        // "You have no plan history" is not an error.
        plans.clear();
        _historyLoaded = true;
      } else {
        historyError.value = res.message;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Plan history failed', error: error, stackTrace: stackTrace);
      historyError.value = 'Could not load your transactions.';
    } finally {
      historyLoading.value = false;
    }
  }

  // ---- Delete account ---------------------------------------------------------

  Future<void> deleteAccount() async {
    final yes = await Get.dialog<bool>(
      const CompleteDialog(
        title: 'Delete Account',
        message: 'Are you sure you want to delete your account? This cannot '
            'be undone.',
      ),
      barrierColor: const Color(0xB3000000),
    );
    if (yes != true) return;
    // TODO(api): no delete-account endpoint has been provided yet.
    AppToast.info('Account deletion is coming soon');
  }

  @override
  void onClose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
