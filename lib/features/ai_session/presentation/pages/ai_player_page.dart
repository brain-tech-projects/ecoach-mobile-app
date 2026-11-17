import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/core/widgets/video/app_video_player.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_player_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/widgets/ai_widgets.dart';

/// Drill video + details + "This session" list.
class AiPlayerPage extends GetView<AiPlayerController> {
  const AiPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 12 * s;
    final c = controller;

    return SubPageScaffold(
      title: 'AI Training Session',
      navIndex: MainNav.trainingIndex,
      body: Obx(() {
        final i = c.index.value;
        final d = c.session.drills[i];
        return SingleChildScrollView(
          controller: c.scroll,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 24 * s, hPad, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 22 * s, vertical: 10 * s),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(40 * s)),
                    child: Text('Drill ${i + 1} of ${c.total}', style: aiText(s, 22, w: FontWeight.w700, c: AppColors.black)),
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    label: 'Exit session',
                    child: GestureDetector(onTap: c.exit, behavior: HitTestBehavior.opaque, child: Padding(padding: EdgeInsets.all(6 * s), child: Text('Exit session', style: aiText(s, 20, w: FontWeight.w500, deco: TextDecoration.underline)))),
                  ),
                ],
              ),
              SizedBox(height: 14 * s),
              ClipRRect(
                borderRadius: BorderRadius.circular(8 * s),
                child: Container(
                  height: 6 * s,
                  color: AppColors.progressTrack,
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(duration: const Duration(milliseconds: 300), alignment: Alignment.centerLeft, widthFactor: c.progress, child: Container(color: AppColors.selectGreen)),
                ),
              ),
              SizedBox(height: 24 * s),
              AppVideoPlayer(key: ValueKey<int>(d.id), url: d.videoUrl, height: 207, scale: s),
              SizedBox(height: 18 * s),
              Semantics(header: true, child: Text(d.title, style: aiText(s, 26, w: FontWeight.w700, h: 1.3))),
              SizedBox(height: 12 * s),
              Wrap(
                spacing: 8 * s,
                runSpacing: 8 * s,
                children: <Widget>[
                  AiTag(label: d.category, scale: s, size: 17),
                  AiTag(label: '${d.mins} mins', icon: Icons.schedule, scale: s, size: 17),
                  AiTag(label: '+${d.points} points', scale: s, size: 17),
                ],
              ),
              SizedBox(height: 20 * s),
              Text(d.description, style: aiText(s, 17, c: AppColors.descGrey, h: 1.55)),
              SizedBox(height: 20 * s),
              AiNote(text: d.note, scale: s, size: 16),
              SizedBox(height: 24 * s),
              Row(
                children: <Widget>[
                  SizedBox(width: 112 * s, child: AiOutlineButton(label: 'Previous', onTap: c.previous, scale: s, height: 50, enabled: !c.isFirst)),
                  SizedBox(width: 16 * s),
                  Expanded(child: AppPrimaryButton(label: c.isLast ? 'Finish Session' : 'Next Drill', onPressed: c.next, scale: s)),
                ],
              ),
              SizedBox(height: 26 * s),
              AiCard(
                scale: s,
                padding: EdgeInsets.all(17 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(header: true, child: Text('This session', style: aiText(s, 21, w: FontWeight.w600))),
                    SizedBox(height: 16 * s),
                    for (var k = 0; k < c.total; k++)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10 * s),
                        child: _SessionRow(title: c.session.drills[k].title, mins: c.session.drills[k].mins, number: k + 1, done: k < i, current: k == i, scale: s, onTap: () => c.jumpTo(k)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.title, required this.mins, required this.number, required this.done, required this.current, required this.scale, required this.onTap});
  final String title;
  final int mins;
  final int number;
  final bool done;
  final bool current;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      selected: current,
      label: 'Drill $number, $title${done ? ', completed' : ''}',
      child: ExcludeSemantics(
        child: Material(
          color: current ? const Color(0xFF2E5448) : aiRowFill,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * s), side: current ? const BorderSide(color: AppColors.selectGreen, width: 1.5) : BorderSide.none),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * s)),
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 55 * s),
              padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
              child: Row(
                children: <Widget>[
                  done
                      ? Container(width: 25 * s, height: 25 * s, decoration: BoxDecoration(color: AppColors.selectGreen, borderRadius: BorderRadius.circular(6 * s)), child: Icon(Icons.check, size: 19 * s, color: AppColors.white))
                      : Container(
                          width: 32 * s,
                          height: 32 * s,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8 * s), border: Border.all(color: AppColors.unselectedBorder, width: 1.3)),
                          child: Text('$number', style: aiText(s, 17, w: FontWeight.w500)),
                        ),
                  SizedBox(width: done ? 24 * s : 20 * s),
                  Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: aiText(s, 18))),
                  SizedBox(width: 8 * s),
                  Text('${mins}m', style: aiText(s, 18, c: AppColors.descGrey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
