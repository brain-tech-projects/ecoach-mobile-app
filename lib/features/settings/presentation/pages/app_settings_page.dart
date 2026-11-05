import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_asset_icon.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/settings/presentation/controllers/app_settings_controller.dart';
import 'package:ecoach_pro/features/settings/presentation/widgets/settings_section.dart';
import 'package:ecoach_pro/features/settings/presentation/widgets/terms_accordion.dart';

class AppSettingsPage extends GetView<AppSettingsController> {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final gap = SizedBox(height: 12 * s);

    return SubPageScaffold(
      title: 'App Settings',
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          r.gutter + 24 * s,
          28.3 * s,
          r.gutter + 24 * s,
          24 * s,
        ),
        child: Obx(() {
          final open = controller.open.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TermsAccordion(
                expanded: open == AppSettingsController.terms,
                onToggle: () => controller.toggle(AppSettingsController.terms),
                scale: s,
              ),
              gap,
              SettingsSection(
                title: 'Change Password',
                scale: s,
                expanded: open == AppSettingsController.password,
                onToggle: () => controller.toggle(AppSettingsController.password),
                child: _PasswordForm(controller: controller, scale: s),
              ),
              gap,
              SettingsSection(
                title: 'Transaction History',
                scale: s,
                expanded: open == AppSettingsController.history,
                onToggle: () => controller.toggle(AppSettingsController.history),
                child: _History(controller: controller, scale: s),
              ),
              SizedBox(height: 16 * s),
              Semantics(
                button: true,
                label: 'Delete Account',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.deleteAccount,
                  child: Container(
                    height: 52.7 * s,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 19.3 * s),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(11.5 * s),
                    ),
                    child: Text(
                      'Delete Account',
                      style: AppTextStyles.termsHeader
                          .scaled(s)
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({required this.controller, required this.scale});

  final AppSettingsController controller;
  final double scale;

  Widget _eye(bool obscured, VoidCallback onTap) => InkResponse(
    onTap: onTap,
    child: Center(
      child: obscured
          ? AppAssetIcon(
              AppAssets.iconEyeOff,
              width: 24 * scale,
              height: 22 * scale,
              color: AppColors.hint,
            )
          : Icon(Icons.visibility_outlined, size: 24 * scale, color: AppColors.hint),
    ),
  );

  Widget _field(
    TextEditingController c,
    String hint,
    RxBool obscure,
    TextInputAction action,
  ) => Obx(
    () => AuthTextField(
      controller: c,
      hint: hint,
      iconAsset: AppAssets.iconLock,
      iconWidth: 15.7,
      iconHeight: 18.7,
      obscureText: obscure.value,
      textInputAction: action,
      scale: scale,
      suffix: _eye(obscure.value, () => obscure.value = !obscure.value),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: AppColors.termsContentFill,
        borderRadius: BorderRadius.circular(11.5 * s),
      ),
      child: Column(
        children: <Widget>[
          _field(controller.currentController, 'Enter Current Password',
              controller.obscureCurrent, TextInputAction.next),
          SizedBox(height: 12 * s),
          _field(controller.newController, 'Enter New Password',
              controller.obscureNew, TextInputAction.next),
          SizedBox(height: 12 * s),
          _field(controller.confirmController, 'Re-type New Password',
              controller.obscureConfirm, TextInputAction.done),
          SizedBox(height: 16 * s),
          Obx(
            () => AppPrimaryButton(
              label: 'Update',
              loading: controller.savingPassword.value,
              onPressed: controller.changePassword,
              scale: s,
            ),
          ),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.controller, required this.scale});

  final AppSettingsController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final head = AppTextStyles.programTitle.scaled(s * 0.8);
    final cell = AppTextStyles.programDesc.scaled(s * 0.95).copyWith(color: AppColors.white);

    Widget pad(Widget w) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 10 * s),
      child: w,
    );

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: AppColors.termsContentFill,
        borderRadius: BorderRadius.circular(11.5 * s),
      ),
      child: Obx(() {
        if (controller.historyLoading.value) {
          return Padding(
            padding: EdgeInsets.all(16 * s),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
          );
        }
        final error = controller.historyError.value;
        if (error != null) {
          return Column(
            children: <Widget>[
              Text(error, style: AppTextStyles.programDesc.scaled(s)),
              TextButton(
                onPressed: controller.loadHistory,
                child: Text('Retry', style: AppTextStyles.action.scaled(s)),
              ),
            ],
          );
        }
        final plans = controller.plans.toList();
        if (plans.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(12 * s),
            child: Text(
              'You have no plan history yet.',
              style: AppTextStyles.programDesc.scaled(s),
            ),
          );
        }

        String date(DateTime? d) => d == null ? '-' : PlayerFormat.dob(d);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth(96 * s),
              1: FixedColumnWidth(84 * s),
              2: FixedColumnWidth(96 * s),
              3: FixedColumnWidth(90 * s),
              4: FixedColumnWidth(90 * s),
            },
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  for (final h in <String>['PLAN', 'AMOUNT', 'STATUS', 'START', 'END'])
                    pad(Text(h, style: head)),
                ],
              ),
              for (final p in plans)
                TableRow(
                  children: <Widget>[
                    pad(Text(p.plan, style: cell)),
                    pad(Text(p.amount, style: cell)),
                    pad(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
                          decoration: BoxDecoration(
                            color: (p.status.toLowerCase() == 'active'
                                    ? AppColors.selectGreen
                                    : AppColors.hint)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12 * s),
                          ),
                          child: Text(
                            p.status,
                            style: cell.copyWith(
                              color: p.status.toLowerCase() == 'active'
                                  ? AppColors.selectGreen
                                  : AppColors.hint,
                              fontSize: 11 * s,
                            ),
                          ),
                        ),
                      ),
                    ),
                    pad(Text(date(p.startsAt), style: cell)),
                    pad(Text(date(p.endsAt), style: cell)),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }
}
