import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/features/coach_portal/data/coach_portal_repository.dart';
import 'package:ecoach_pro/features/coach_portal/domain/coach_portal_entities.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/widgets/coach_widgets.dart';

const Color _barrier = Color(0x99000000);
const Color _cardBg = Color(0xFF0C3846);
const Color _cardBorder = Color(0xFF2A5866);
const Color _divider = Color(0xFF2A5866);
const Color _line = Color(0xFF2E5965);
const Color _dot = Color(0xFF3E6672);
const Color _muted = Color(0xFF9DB3BA);
const Color _closeBg = Color(0xFF1C4A57);
const Color _aiPillBg = Color(0xFF2E4B57);
const Color _aiPink = Color(0xFFF28BA8);
const Color _check = Color(0xFF4AD82B);

/// Opens the history behind one Coaches Summary cell.
/// The header shows [player] at once; the list loads from `coach-summary-detail`.
Future<void> showSummaryDetailDialog({
  required CoachPlayer player,
  required SummaryDetailType type,
  required bool lastSevenDays,
  required String season,
}) {
  ensureCoachPortalRepository();
  return Get.dialog<void>(
    SummaryDetailDialog(player: player, type: type, lastSevenDays: lastSevenDays, season: season),
    barrierColor: _barrier,
  );
}

class SummaryDetailDialog extends StatefulWidget {
  const SummaryDetailDialog({
    super.key,
    required this.player,
    required this.type,
    required this.lastSevenDays,
    required this.season,
  });

  final CoachPlayer player;
  final SummaryDetailType type;
  final bool lastSevenDays;
  final String season;

  @override
  State<SummaryDetailDialog> createState() => _SummaryDetailDialogState();
}

class _SummaryDetailDialogState extends State<SummaryDetailDialog> {
  SummaryDetail? _detail;
  String? _error;
  bool _loading = true;

  bool get _isAi => widget.type == SummaryDetailType.aiSessions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await Get.find<CoachPortalRepository>().fetchSummaryDetail(
        playerId: widget.player.id,
        type: widget.type,
        season: widget.season,
      );
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (e, st) {
      AppLogger.error('Summary detail failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _error = e is ApiException ? e.message : 'Could not load the details.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    final player = _detail?.player ?? widget.player;
    final range = widget.lastSevenDays ? 'LAST 7 DAYS' : 'ALL TIME';
    final label = '${widget.type.label} · $range';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: _cardBg,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        insetPadding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 40 * s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * s),
          side: const BorderSide(color: _cardBorder),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(player: player, label: label, aiPill: _isAi, scale: s),
              const Divider(height: 1, thickness: 1, color: _divider),
              Flexible(child: _body(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(double s) {
    if (_loading) {
      return Padding(padding: EdgeInsets.symmetric(vertical: 48 * s), child: const AppLoader());
    }
    if (_error != null) return CoachEmpty(text: _error!, onRetry: _load);
    final items = _detail?.items(lastSevenDays: widget.lastSevenDays) ?? const <SummaryHistoryItem>[];
    if (items.isEmpty) return const CoachEmpty(text: 'No records found.');

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(0, 16 * s, 18 * s, 24 * s),
      itemCount: items.length,
      itemBuilder: (_, i) => _TimelineItem(
        item: items[i],
        ai: _isAi,
        isLast: i == items.length - 1,
        scale: s,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.player, required this.label, required this.aiPill, required this.scale});

  final CoachPlayer player;
  final String label;
  final bool aiPill;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final flag = coachFlag(player.countryCode);
    final labelStyle = AppTextStyles.programTitle.scaled(s).copyWith(
      fontSize: 13 * s,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: AppColors.white,
    );

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(children: <InlineSpan>[
            TextSpan(
              text: player.name,
              style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 19 * s, fontWeight: FontWeight.w700, color: AppColors.white),
            ),
            if (flag != null) TextSpan(text: ' $flag', style: TextStyle(fontSize: 15 * s)),
          ]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (player.subtitle.isNotEmpty)
          Text(
            player.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 14 * s, color: _muted),
          ),
      ],
    );

    final close = Semantics(
      button: true,
      label: 'Close',
      child: Material(
        color: _closeBg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Get.back<void>(),
          child: SizedBox(
            width: 30 * s,
            height: 30 * s,
            child: Icon(Icons.close_rounded, size: 18 * s, color: AppColors.white.withValues(alpha: 0.8)),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 12 * s, aiPill ? 16 * s : 20 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: aiPill ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: <Widget>[
              CoachPlayerAvatar(url: player.photoUrl, size: 42 * s),
              SizedBox(width: 12 * s),
              Expanded(child: identity),
              if (aiPill) ...<Widget>[
                SizedBox(width: 8 * s),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
                    decoration: BoxDecoration(color: _aiPillBg, borderRadius: BorderRadius.circular(20 * s)),
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: labelStyle.copyWith(color: _aiPink, fontSize: 11.5 * s),
                    ),
                  ),
                ),
              ],
              SizedBox(width: 6 * s),
              close,
            ],
          ),
          if (!aiPill) ...<Widget>[
            SizedBox(height: 14 * s),
            Padding(
              padding: EdgeInsets.only(left: 10 * s),
              child: Semantics(header: true, child: Text(label, style: labelStyle)),
            ),
          ],
        ],
      ),
    );
  }
}

/// One entry with the thin timeline on its left (AI sessions: dot + drills).
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item, required this.ai, required this.isLast, required this.scale});

  final SummaryHistoryItem item;
  final bool ai;
  final bool isLast;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final lineX = 27 * s;
    final textX = 43 * s;
    final dotSize = 8 * s;
    final at = item.completedAt;

    final content = Padding(
      padding: EdgeInsets.only(left: textX, bottom: 16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ai ? '"${item.title}"' : item.title,
            style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 16 * s, fontWeight: FontWeight.w600, color: AppColors.white, height: 1.3),
          ),
          if (at != null) ...<Widget>[
            SizedBox(height: 3 * s),
            Text(
              formatSummaryTime(at),
              style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 13 * s, color: _muted),
            ),
          ],
          if (ai && item.drills.isNotEmpty) ...<Widget>[
            SizedBox(height: 8 * s),
            for (final d in item.drills) _DrillRow(drill: d, scale: s),
          ],
        ],
      ),
    );

    return Stack(
      children: <Widget>[
        if (ai)
          Positioned(
            left: lineX - 0.5,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: isLast ? Colors.transparent : _line),
          )
        else if (!isLast)
          Positioned(
            left: lineX - 0.5,
            top: 22 * s,
            bottom: 4 * s,
            child: Container(width: 1, color: _line),
          ),
        if (ai)
          Positioned(
            left: lineX - dotSize / 2,
            top: 7 * s,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: const BoxDecoration(color: _dot, shape: BoxShape.circle),
            ),
          ),
        Semantics(
          label: at == null ? item.title : '${item.title}, ${formatSummaryTime(at)}',
          excludeSemantics: !ai,
          child: content,
        ),
      ],
    );
  }
}

class _DrillRow extends StatelessWidget {
  const _DrillRow({required this.drill, required this.scale});

  final SummaryDrill drill;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(bottom: 5 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 18 * s,
            height: 18 * s,
            margin: EdgeInsets.only(top: 1 * s),
            decoration: BoxDecoration(
              color: drill.completed ? _check : Colors.transparent,
              borderRadius: BorderRadius.circular(3 * s),
              border: drill.completed ? null : Border.all(color: _muted),
            ),
            child: drill.completed ? Icon(Icons.check_rounded, size: 14 * s, color: AppColors.white) : null,
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Text(
              drill.title,
              style: AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 14 * s, color: AppColors.white, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
