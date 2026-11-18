import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_result_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/widgets/ai_widgets.dart';

/// "Here's your session" - summary typed word by word + the 4 drills.
class AiResultPage extends GetView<AiResultController> {
  const AiResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 12 * s;
    final c = controller;
    final session = c.session;

    return SubPageScaffold(
      title: 'AI Training Session',
      navIndex: MainNav.trainingIndex,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(hPad, 24 * s, hPad, 24 * s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ---- AI card ----
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16 * s, 18 * s, 16 * s, 20 * s),
              decoration: BoxDecoration(color: aiPanel, borderRadius: BorderRadius.circular(30 * s), border: Border.all(color: const Color(0xFF3DDBC0), width: 1.5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 8 * s), child: AiAvatar(size: 38 * s)),
                  SizedBox(width: 18 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('eCoach AI', style: aiText(s, 20, w: FontWeight.w700)),
                        SizedBox(height: 6 * s),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
                          decoration: BoxDecoration(color: const Color(0xFF14504A), borderRadius: BorderRadius.circular(30 * s)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[Icon(Icons.verified_user_outlined, size: 16 * s, color: const Color(0xFF7DF58A)), SizedBox(width: 8 * s), Flexible(child: Text('Approved eCoach drills only', style: aiText(s, 15, c: const Color(0xFF7DF58A))))],
                          ),
                        ),
                        SizedBox(height: 6 * s),
                        Semantics(
                          header: true,
                          child: Text.rich(TextSpan(children: <InlineSpan>[
                            TextSpan(text: "Here's your session, ", style: aiText(s, 26, w: FontWeight.w700, h: 1.3)),
                            TextSpan(text: c.firstName, style: aiText(s, 26, w: FontWeight.w700, h: 1.3, c: const Color(0xFF55E39A))),
                          ])),
                        ),
                        SizedBox(height: 8 * s),
                        Text('"${session.request}"', style: aiText(s, 17, c: AppColors.descGrey, h: 1.45, style: FontStyle.italic)),
                        SizedBox(height: 12 * s),
                        // Typed summary: full text reserves the space, unseen words are transparent.
                        Obx(() {
                          final n = c.shown.value;
                          final seen = c.words.take(n).join(' ');
                          final rest = c.words.skip(n).join(' ');
                          return Semantics(
                            label: session.summary,
                            child: ExcludeSemantics(
                              child: Text.rich(TextSpan(children: <InlineSpan>[
                                TextSpan(text: seen, style: aiText(s, 19, h: 1.5)),
                                TextSpan(text: (n > 0 && rest.isNotEmpty ? ' ' : '') + rest, style: aiText(s, 19, h: 1.5, c: Colors.transparent)),
                              ])),
                            ),
                          );
                        }),
                        SizedBox(height: 14 * s),
                        Wrap(
                          spacing: 8 * s,
                          runSpacing: 8 * s,
                          children: <Widget>[
                            AiTag(label: '${session.totalMins} mins', icon: Icons.schedule, scale: s, size: 17),
                            AiTag(label: '${session.drills.length} drills', scale: s, size: 17),
                            for (final t in session.tags) AiTag(label: t, scale: s, size: 17),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28 * s),
            Row(
              children: <Widget>[
                Expanded(child: Semantics(header: true, child: Text('Your Training Session', style: aiText(s, 21, w: FontWeight.w600)))),
                Text('Up to +${session.totalPoints} points', style: aiText(s, 17, w: FontWeight.w500, c: const Color(0xFF7DF58A))),
              ],
            ),
            SizedBox(height: 16 * s),
            for (var i = 0; i < session.drills.length; i++)
              Padding(padding: EdgeInsets.only(bottom: 16 * s), child: AiDrillCard(drill: session.drills[i], number: i + 1, scale: s, onTap: () => c.openDrill(i))),
            SizedBox(height: 8 * s),
            Obx(() => AppPrimaryButton(label: 'Start Training', onPressed: c.start, loading: c.starting.value, scale: s)),
            SizedBox(height: 18 * s),
            Row(
              children: <Widget>[
                Expanded(child: AiOutlineButton(label: 'Edit request', onTap: () => c.backToHome(keepRequest: true), scale: s, height: 50)),
                SizedBox(width: 16 * s),
                Expanded(child: AiOutlineButton(label: 'New session', onTap: () => c.backToHome(keepRequest: false), scale: s, height: 50)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
