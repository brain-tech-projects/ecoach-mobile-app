import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/summary_controller.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

const Color _headBg = Color(0xFF1A3A47);
const Color _rowBg = Color(0xFF20404B);

class _Group {
  const _Group(this.title, this.color);
  final String title;
  final Color color;
}

const List<_Group> _groups = <_Group>[
  _Group('SKILLS', Color(0xFF6AA7F8)),
  _Group('SESSIONS', Color(0xFF7ED957)),
  _Group('TRAINING', Color(0xFFF2B15B)),
  _Group('QUIZZES', Color(0xFFA79BFF)),
  _Group('TRACKER', Color(0xFF4ED8C4)),
  _Group('AI SESSIONS', Color(0xFFF28BA8)),
];

class SummaryPage extends GetView<SummaryController> {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 28 * s;

    return SubPageScaffold(
      title: 'Coaches Summary',
      navIndex: -1,
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 28 * s, hPad, 24 * s),
        children: <Widget>[
          LayoutBuilder(
            builder: (_, box) {
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text.rich(TextSpan(children: <InlineSpan>[
                      TextSpan(text: 'Coach ', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 30 * s, fontWeight: FontWeight.w700)),
                      TextSpan(text: 'Summary', style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 30 * s, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    ])),
                  ),
                  SizedBox(height: 4 * s),
                  Text('Overview of player training progress', style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 17 * s)),
                ],
              );
              final season = Obx(() => _SeasonDropdown(value: controller.season.value, onChanged: controller.selectSeason));
              if (box.maxWidth > 640 * s) {
                return Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[Expanded(child: heading), season]);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[heading, SizedBox(height: 22 * s), season]);
            },
          ),
          SizedBox(height: 22 * s),
          Obx(() {
            if (controller.loading.value) return Padding(padding: EdgeInsets.symmetric(vertical: 60 * s), child: const AppLoader());
            if (controller.rows.isEmpty) return const CoachEmpty(text: 'No players to summarise yet.');
            return _Table(rows: controller.rows.toList(), scale: s);
          }),
        ],
      ),
    );
  }
}

/// Season pill; the list opens right below it (selected row blue with a check).
class _SeasonDropdown extends StatefulWidget {
  const _SeasonDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_SeasonDropdown> createState() => _SeasonDropdownState();
}

class _SeasonDropdownState extends State<_SeasonDropdown> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final seasons = CoachPortalRepository.seasons;
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              button: true,
              expanded: _open,
              label: widget.value,
              child: GestureDetector(
                onTap: () => setState(() => _open = !_open),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 14 * s),
                  decoration: BoxDecoration(color: const Color(0xFF173642), borderRadius: BorderRadius.circular(16 * s), border: Border.all(color: const Color(0xFF2B4B57))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.calendar_today_outlined, color: AppColors.accent, size: 20 * s),
                      SizedBox(width: 12 * s),
                      Text(widget.value, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 18 * s, fontWeight: FontWeight.w600)),
                      SizedBox(width: 10 * s),
                      Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.white, size: 20 * s),
                    ],
                  ),
                ),
              ),
            ),
            if (_open)
              Container(
                margin: EdgeInsets.only(top: 6 * s),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFF071B1F), borderRadius: BorderRadius.circular(10 * s)),
                child: Column(
                  children: <Widget>[
                    for (final v in seasons)
                      InkWell(
                        onTap: () {
                          setState(() => _open = false);
                          widget.onChanged(v);
                        },
                        child: Container(
                          height: 44 * s,
                          padding: EdgeInsets.symmetric(horizontal: 14 * s),
                          color: v == widget.value ? const Color(0xFF1558B8) : Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 18 * s, child: v == widget.value ? Icon(Icons.check, size: 14 * s, color: AppColors.white) : null),
                              SizedBox(width: 6 * s),
                              Expanded(child: Text(v, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 15 * s, fontWeight: FontWeight.w400))),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sticky PLAYER column + horizontally scrollable stats; stretches on wide screens.
class _Table extends StatelessWidget {
  const _Table({required this.rows, required this.scale});
  final List<SummaryRow> rows;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final playerW = 132 * s;
    final allocW = 84 * s;
    final headTop = 34 * s;
    final headSub = 30 * s;
    final rowH = 68 * s;

    return LayoutBuilder(
      builder: (_, box) {
        const cols = 12;
        final base = 62 * s;
        final cell = box.maxWidth > playerW + allocW + cols * base ? (box.maxWidth - playerW - allocW) / cols : base;
        final head = AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 12 * s, fontWeight: FontWeight.w700, letterSpacing: 1);
        final sub = AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 12 * s);

        Widget groupHead(_Group g) => SizedBox(
          width: cell * 2,
          child: Column(
            children: <Widget>[
              Container(height: headTop, alignment: Alignment.center, color: g.color.withValues(alpha: 0.14), child: Text(g.title, style: head.copyWith(color: g.color))),
              SizedBox(
                height: headSub,
                child: Row(children: <Widget>[for (final t in const <String>['All Time', 'Last 7 Days']) SizedBox(width: cell, child: Center(child: Text(t, textAlign: TextAlign.center, style: sub)))]),
              ),
            ],
          ),
        );

        Widget valueCell(int v, Color c) => SizedBox(
          width: cell,
          height: rowH,
          child: Center(
            child: Container(
              width: 34 * s,
              height: 34 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Text('$v', style: AppTextStyles.programTitle.scaled(s).copyWith(color: c.withValues(alpha: 0.9), fontSize: 14 * s, fontWeight: FontWeight.w700)),
            ),
          ),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(20 * s),
          child: Container(
            color: _headBg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Sticky player column
                SizedBox(
                  width: playerW,
                  child: Column(
                    children: <Widget>[
                      Container(height: headTop + headSub, alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 16 * s), child: Text('PLAYER', style: head.copyWith(color: AppColors.white, fontSize: 14 * s))),
                      for (final row in rows)
                        Container(
                          height: rowH,
                          color: const Color(0xFF244A44),
                          padding: EdgeInsets.symmetric(horizontal: 10 * s),
                          child: Row(
                            children: <Widget>[
                              Container(width: 32 * s, height: 32 * s, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.25), shape: BoxShape.circle), child: Text(row.player.name.isEmpty ? '?' : row.player.name[0].toUpperCase(), style: AppTextStyles.programTitle.scaled(s).copyWith(color: AppColors.accent, fontWeight: FontWeight.w700))),
                              SizedBox(width: 8 * s),
                              Expanded(
                                child: Text.rich(
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  TextSpan(children: <InlineSpan>[
                                    TextSpan(text: row.player.name, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 13 * s, fontWeight: FontWeight.w700)),
                                    if (coachFlag(row.player.countryCode) != null) TextSpan(text: ' ${coachFlag(row.player.countryCode)}', style: TextStyle(fontSize: 13 * s)),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            for (final g in _groups) groupHead(g),
                            Container(
                              width: allocW,
                              height: headTop + headSub,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 6 * s),
                              child: Text('ALLOCATED TRAINING COMPLETED', textAlign: TextAlign.center, style: head.copyWith(color: AppColors.accent, fontSize: 11 * s, height: 1.3)),
                            ),
                          ],
                        ),
                        for (final row in rows)
                          Container(
                            color: _rowBg,
                            child: Row(
                              children: <Widget>[
                                for (var i = 0; i < cols; i++) valueCell(row.values[i], _groups[i ~/ 2].color),
                                SizedBox(
                                  width: allocW,
                                  height: rowH,
                                  child: Center(
                                    child: Container(
                                      width: 30 * s,
                                      height: 30 * s,
                                      decoration: BoxDecoration(color: row.allocatedCompleted ? AppColors.accent : const Color(0xFFE5575C), shape: BoxShape.circle),
                                      child: Icon(row.allocatedCompleted ? Icons.check : Icons.close, size: 17 * s, color: AppColors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
