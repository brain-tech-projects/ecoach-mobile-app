import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/fun/presentation/controllers/challenges_controller.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/challenge_card.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/challenge_menu.dart';
import 'package:ecoach_pro/features/fun/presentation/widgets/fun_state_views.dart';

/// 2-column grid of video challenges.
class ChallengesPage extends GetView<ChallengesController> {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 24 * s;
    return SubPageScaffold(
      title: 'Challenges',
      navIndex: MainNav.funIndex,
      body: Obx(() {
        if (controller.isLoading.value) return const FunLoader();
        final error = controller.errorMessage.value;
        if (error != null) {
          return FunErrorView(message: error, onRetry: controller.load, scale: s);
        }
        final items = controller.challenges.toList();
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 28.3 * s, hPad, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Pick a challenge and take on your friends, family or simply improve your skills',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.trainSubline.scaled(s),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 16 * s, hPad, 24 * s),
              sliver: SliverGrid.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.3 * s,
                  crossAxisSpacing: 8.3 * s,
                  mainAxisExtent: 139 * s,
                ),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return ChallengeCard(
                    key: ValueKey<String>(c.id),
                    challenge: c,
                    scale: s,
                    onTap: () => controller.open(c),
                    onFavorite: () => controller.toggleFavorite(c),
                    onMore: (cardContext) {
                      final origin = globalRectOf(cardContext);
                      showChallengeMenu(
                        cardContext,
                        scale: s,
                        onAddNote: () => controller.addNote(c),
                        onShare: () => controller.share(c, origin: origin),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
