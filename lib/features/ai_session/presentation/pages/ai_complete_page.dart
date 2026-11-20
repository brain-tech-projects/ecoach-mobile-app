import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_home_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/widgets/ai_widgets.dart';

/// Arguments of [AiCompletePage].
class AiCompleteArgs {
  const AiCompleteArgs({required this.points});

  /// Points earned in this session (0 = line is hidden).
  final int points;
}

/// Final screen after the last drill: "Session complete!".
class AiCompletePage extends StatelessWidget {
  const AiCompletePage({super.key});

  /// Back to the AI start screen with an empty request.
  void _createAnother() {
    Get.until((r) => r.settings.name == AppRoutes.aiSession || r.isFirst);
    if (Get.isRegistered<AiHomeController>()) {
      Get.find<AiHomeController>().prefill('');
    }
  }

  void _goHome() => Get.offAllNamed<void>(AppRoutes.dashboard);

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 12 * s;
    final args = Get.arguments;
    final points = args is AiCompleteArgs ? args.points : 0;
    final name = aiFirstName();

    return SubPageScaffold(
      title: 'AI Training Session',
      navIndex: MainNav.trainingIndex,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 48 * s, hPad, 24 * s),
        child: Column(
          children: <Widget>[
            Container(
              width: 100 * s,
              height: 100 * s,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2 * s),
              ),
              child: Icon(Icons.fact_check_outlined, size: 52 * s, color: const Color(0xFF14262F)),
            ),
            SizedBox(height: 30 * s),
            Semantics(
              header: true,
              child: Text(
                'Session complete! \u{1F389}',
                textAlign: TextAlign.center,
                style: aiText(s, 24, w: FontWeight.w700, h: 1.3),
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              name.isEmpty
                  ? 'Great work. Your training has been saved to your history.'
                  : 'Great work, $name. Your training has been saved to your history.',
              textAlign: TextAlign.center,
              style: aiText(s, 16, c: const Color(0xFFC9D2D6), h: 1.5),
            ),
            if (points > 0) ...<Widget>[
              SizedBox(height: 20 * s),
              Text(
                '+$points points earned',
                textAlign: TextAlign.center,
                style: aiText(s, 17, w: FontWeight.w500, c: const Color(0xFFC9D2D6)),
              ),
            ],
            SizedBox(height: 26 * s),
            AppPrimaryButton(label: 'Create Another Session', onPressed: _createAnother, scale: s),
            SizedBox(height: 16 * s),
            AiOutlineButton(label: 'Go to Home', onTap: _goHome, scale: s, height: 49),
          ],
        ),
      ),
    );
  }
}
