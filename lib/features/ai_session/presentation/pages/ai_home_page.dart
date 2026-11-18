import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/navigation/main_nav.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/ai_session/data/ai_session_repository.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';
import 'package:ecoach_pro/features/ai_session/presentation/controllers/ai_home_controller.dart';
import 'package:ecoach_pro/features/ai_session/presentation/widgets/ai_widgets.dart';

/// AI Training Session - first screen.
class AiHomePage extends GetView<AiHomeController> {
  const AiHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final hPad = r.gutter + 12 * s;
    final c = controller;

    return SubPageScaffold(
      title: 'AI Training Session',
      navIndex: MainNav.trainingIndex,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(top: 24 * s, bottom: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ---- header ----
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AiAvatar(size: 38 * s),
                    SizedBox(width: 24 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AiTag(label: 'eCoach AI', icon: Icons.auto_awesome, scale: s, size: 16),
                          SizedBox(height: 10 * s),
                          Semantics(header: true, child: Text('Hi ${c.firstName}, what do you want to work on today?', style: aiText(s, 26, w: FontWeight.w700, h: 1.3))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Text('Tap what you want to improve or type it in your own words. eCoach builds a 4-drill session from the approved training library.', style: aiText(s, 16, c: AppColors.descGrey, h: 1.55)),
              ),
              SizedBox(height: 26 * s),
              Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: Text('What do you want to improve?', style: aiText(s, 17, w: FontWeight.w600))),
              SizedBox(height: 12 * s),
              // ---- chips (horizontal) ----
              SizedBox(
                height: 40 * s,
                child: Obx(() {
                  final sel = c.selectedChip.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    itemCount: AiSessionRepository.chips.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8 * s),
                    itemBuilder: (_, i) {
                      final chip = AiSessionRepository.chips[i];
                      return _ImproveChip(chip: chip, selected: sel == chip.label, scale: s, onTap: () => c.selectChip(chip));
                    },
                  );
                }),
              ),
              SizedBox(height: 20 * s),
              // ---- text box ----
              Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: _RequestBox(controller: c, scale: s)),
              SizedBox(height: 16 * s),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Obx(() => AppPrimaryButton(label: 'Create My Training Session', onPressed: c.create, scale: s * 0.95, enabled: c.canCreate.value)),
              ),
              SizedBox(height: 22 * s),
              Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: Text('Or try one of these:', style: aiText(s, 17, w: FontWeight.w600))),
              SizedBox(height: 12 * s),
              SizedBox(
                height: 40 * s,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  itemCount: AiSessionRepository.suggestions.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8 * s),
                  itemBuilder: (_, i) => _SuggestionPill(text: AiSessionRepository.suggestions[i], scale: s, onTap: () => c.useSuggestion(AiSessionRepository.suggestions[i])),
                ),
              ),
              SizedBox(height: 26 * s),
              Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: _PersonalisedCard(scale: s)),
              SizedBox(height: 22 * s),
              Padding(padding: EdgeInsets.symmetric(horizontal: hPad), child: _RecentCard(controller: c, scale: s)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImproveChip extends StatelessWidget {
  const _ImproveChip({required this.chip, required this.selected, required this.scale, required this.onTap});
  final AiChip chip;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      selected: selected,
      label: chip.label,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? AppColors.selectedFill : Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.selectGreen : AppColors.unselectedBorder, width: selected ? 1.5 : 1.2)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: Row(
                children: <Widget>[
                  Text(chip.emoji, style: TextStyle(fontSize: 16 * s)),
                  SizedBox(width: 14 * s),
                  Text(chip.label, style: aiText(s, 17, w: FontWeight.w500, c: selected ? AppColors.accent : AppColors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestBox extends StatelessWidget {
  const _RequestBox({required this.controller, required this.scale});
  final AiHomeController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minHeight: 125 * s),
      padding: EdgeInsets.fromLTRB(20 * s, 14 * s, 20 * s, 10 * s),
      decoration: BoxDecoration(color: aiPanel, borderRadius: BorderRadius.circular(26 * s), border: Border.all(color: AppColors.selectGreen, width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: controller.input,
            focusNode: controller.focus,
            minLines: 3,
            maxLines: 6,
            maxLength: AiHomeController.maxLength,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: AppColors.accent,
            style: aiText(s, 18, h: 1.4),
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'e.g. I want to work on my first touch and shooting.',
              hintStyle: aiText(s, 18, c: const Color(0xFF8A9AA0), h: 1.4),
            ),
          ),
          SizedBox(height: 10 * s),
          Align(alignment: Alignment.centerRight, child: Obx(() => Text('${controller.count.value}/${AiHomeController.maxLength}', style: aiText(s, 16, c: AppColors.descGrey)))),
        ],
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.text, required this.scale, required this.onTap});
  final String text;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.unselectedBorder, width: 1.2)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22 * s),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 14 * s, color: AppColors.accent),
              SizedBox(width: 12 * s),
              Text(text, style: aiText(s, 17, w: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalisedCard extends StatelessWidget {
  const _PersonalisedCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final p = AiSessionRepository.profile;

    Widget group(String label, List<String> items) => Padding(
      padding: EdgeInsets.only(bottom: 18 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: aiText(s, 17, c: AppColors.descGrey)),
          SizedBox(height: 8 * s),
          Wrap(spacing: 8 * s, runSpacing: 8 * s, children: <Widget>[for (final e in items) AiTag(label: e, scale: s, size: 17)]),
        ],
      ),
    );

    return AiCard(
      scale: s,
      padding: EdgeInsets.fromLTRB(17 * s, 17 * s, 17 * s, 17 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[Icon(Icons.auto_awesome, size: 22 * s, color: AppColors.accent), SizedBox(width: 12 * s), Semantics(header: true, child: Text('Personalised for you', style: aiText(s, 21, w: FontWeight.w600)))]),
          SizedBox(height: 14 * s),
          if (p.age.isNotEmpty) group('Age', <String>[p.age]),
          if (p.positions.isNotEmpty) group('Position', p.positions),
          if (p.levels.isNotEmpty) group('Level', p.levels),
          if (p.focus.isNotEmpty) group('Focus areas', p.focus),
          AiShieldNote(scale: s),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.controller, required this.scale});
  final AiHomeController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return AiCard(
      scale: s,
      child: Obx(() {
        final items = controller.visibleRecent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(header: true, child: Text('Recent AI sessions', style: aiText(s, 21, w: FontWeight.w600))),
            SizedBox(height: 16 * s),
            if (controller.loading.value)
              Padding(padding: EdgeInsets.symmetric(vertical: 24 * s), child: const Center(child: CircularProgressIndicator(color: AppColors.accent)))
            else if (items.isEmpty)
              Text('No sessions yet. Create your first one above.', style: aiText(s, 16, c: AppColors.descGrey))
            else
              for (final e in items)
                Padding(
                  padding: EdgeInsets.only(bottom: 16 * s),
                  child: _RecentItem(item: e, scale: s, onOpen: () => controller.open(e), onNew: () => controller.newVersion(e)),
                ),
            if (controller.hiddenCount > 0)
              Center(
                child: TextButton(
                  onPressed: controller.toggleMore,
                  child: Text(controller.expanded.value ? 'Show less' : 'Show more (${controller.hiddenCount})', style: aiText(s, 18, w: FontWeight.w600, c: AppColors.accent)),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({required this.item, required this.scale, required this.onOpen, required this.onNew});
  final AiSessionSummary item;
  final double scale;
  final VoidCallback onOpen;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(color: aiRowFill, borderRadius: BorderRadius.circular(20 * s), border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.7))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('"${item.request}"', style: aiText(s, 19, w: FontWeight.w500, h: 1.45)),
          SizedBox(height: 8 * s),
          Text('${item.when}  •  ${item.drills} drills  •  ${item.mins} mins', style: aiText(s, 17, c: AppColors.descGrey)),
          SizedBox(height: 14 * s),
          Row(
            children: <Widget>[
              Expanded(flex: 4, child: AiFilledButton(label: 'Open', icon: Icons.play_arrow_rounded, onTap: onOpen, scale: s)),
              SizedBox(width: 8 * s),
              Expanded(flex: 5, child: AiOutlineButton(label: 'New version', onTap: onNew, scale: s)),
            ],
          ),
        ],
      ),
    );
  }
}
