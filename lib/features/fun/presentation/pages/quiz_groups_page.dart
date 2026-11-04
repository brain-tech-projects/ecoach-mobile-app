import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/quiz_groups_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/quiz_list_tile.dart';

class QuizGroupsPage extends GetView<QuizGroupsController> {
  const QuizGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    return SubPageScaffold(
      title: 'Quizzes',
      navIndex: MainNav.funIndex,
      body: Obx(() {
        if (controller.isLoading.value) return const FunLoader();
        final error = controller.errorMessage.value;
        if (error != null) {
          return FunErrorView(message: error, onRetry: controller.load, scale: s);
        }
        final items = controller.groups.toList();
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(hPad, 28.3 * s, hPad, 24 * s),
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: 8 * s),
          itemBuilder: (context, i) {
            final item = items[i];
            return QuizListTile(
              title: item.name,
              logo: item.logo,
              scale: s,
              onTap: () => controller.open(item),
            );
          },
        );
      }),
    );
  }
}
