import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_building_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/widgets/ai_widgets.dart';

/// "Building your session" - fixed orb, 4 steps tick one by one, then auto-navigates.
class AiBuildingPage extends GetView<AiBuildingController> {
  const AiBuildingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 12 * s;
    final c = controller;

    return SubPageScaffold(
      title: 'AI Training Session',
      navIndex: MainNav.trainingIndex,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 24 * s),
        child: Column(
          children: <Widget>[
            AiOrb(size: 128 * s),
            SizedBox(height: 24 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 12 * s),
              decoration: BoxDecoration(color: aiTeal, borderRadius: BorderRadius.circular(40 * s)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Icon(Icons.auto_awesome, size: 18 * s, color: AppColors.white), SizedBox(width: 14 * s), Text('eCoach AI is thinking', style: aiText(s, 18, w: FontWeight.w500))],
              ),
            ),
            SizedBox(height: 22 * s),
            Semantics(header: true, child: Text('Building your session', textAlign: TextAlign.center, style: aiText(s, 29, w: FontWeight.w700))),
            SizedBox(height: 8 * s),
            Text('"${c.request}"', textAlign: TextAlign.center, style: aiText(s, 17, c: AppColors.descGrey, h: 1.45)),
            SizedBox(height: 26 * s),
            Obx(() {
              final done = c.done.value;
              return Column(
                children: <Widget>[
                  for (var i = 0; i < c.steps.length; i++)
                    Padding(padding: EdgeInsets.only(bottom: 10 * s), child: _StepRow(text: c.steps[i], state: i < done ? _St.done : (i == done ? _St.active : _St.pending), scale: s)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum _St { done, active, pending }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.text, required this.state, required this.scale});
  final String text;
  final _St state;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final done = state == _St.done;
    final active = state == _St.active;
    return Semantics(
      label: '$text, ${done ? 'done' : active ? 'in progress' : 'waiting'}',
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: BoxConstraints(minHeight: 49 * s),
          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: active ? AppColors.selectGreen : AppColors.cardBorder.withValues(alpha: 0.7), width: active ? 1.4 : 1.2),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 22 * s,
                height: 22 * s,
                child: done
                    ? Container(decoration: BoxDecoration(color: AppColors.selectGreen, borderRadius: BorderRadius.circular(6 * s)), child: Icon(Icons.check, size: 17 * s, color: AppColors.white))
                    : AiDots(size: 22 * s, active: active),
              ),
              SizedBox(width: 18 * s),
              Expanded(child: Text(text, style: aiText(s, 18, c: done ? AppColors.white : AppColors.descGrey, h: 1.5))),
            ],
          ),
        ),
      ),
    );
  }
}
