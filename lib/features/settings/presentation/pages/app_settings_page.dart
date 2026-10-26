import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/settings/presentation/controllers/app_settings_controller.dart';
import 'package:ecoach_pro/features/settings/presentation/widgets/terms_accordion.dart';

class AppSettingsPage extends GetView<AppSettingsController> {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'App Settings',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.gutter + 24 * s,
          28.3 * s,
          r.gutter + 24 * s,
          24 * s,
        ),
        child: Obx(
          () => TermsAccordion(
            expanded: controller.termsExpanded.value,
            onToggle: controller.toggleTerms,
            scale: s,
          ),
        ),
      ),
    );
  }
}
