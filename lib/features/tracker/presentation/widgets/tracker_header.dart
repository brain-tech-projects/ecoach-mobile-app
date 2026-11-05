import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';

const Color _tileFill = Color(0xFF3F6357);
const Color _tileEdge = Color(0xFF507E64);

/// Shield-shaped player photo.
class ShieldPhoto extends StatelessWidget {
  const ShieldPhoto({super.key, required this.data, required this.scale});

  final TrackerData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget fallback() => const ColoredBox(
          color: AppColors.avatarBg,
          child: Icon(Icons.person, size: 44, color: AppColors.avatarFg),
        );
    Widget img;
    if (data.photoAsset != null) {
      img = Image.asset(data.photoAsset!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else if (data.photoUrl != null) {
      img = Image.network(data.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
    } else {
      img = fallback();
    }
    return ExcludeSemantics(
      child: SizedBox(
        width: 86 * s,
        height: 103 * s,
        child: ClipPath(clipper: _ShieldClipper(), child: img),
      ),
    );
  }
}

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.155)
      ..lineTo(w, h * 0.62)
      ..cubicTo(w, h * 0.82, w * 0.72, h * 0.93, w / 2, h)
      ..cubicTo(w * 0.28, h * 0.93, 0, h * 0.82, 0, h * 0.62)
      ..lineTo(0, h * 0.155)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Shield photo + player card with Goals / Assists / Saves.
class TrackerSummary extends StatelessWidget {
  const TrackerSummary({super.key, required this.data, required this.scale});

  final TrackerData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      container: true,
      label: '${data.playerName}. ${data.goals} goals, ${data.assists} assists, ${data.saves} saves',
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 59 * s),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(11 * s, 58 * s, 11 * s, 11 * s),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: <Widget>[
                  ExcludeSemantics(child: _NameRow(name: data.playerName, scale: s)),
                  SizedBox(height: 24 * s),
                  ExcludeSemantics(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _StatTile(
                            icon: const Icon(Icons.track_changes, color: AppColors.accent),
                            value: data.goals,
                            label: 'Goals',
                            scale: s,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: _StatTile(
                            icon: const Icon(Icons.volunteer_activism_outlined, color: AppColors.accent),
                            value: data.assists,
                            label: 'Assists',
                            scale: s,
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: _StatTile(
                            icon: const Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Icon(Icons.shield_outlined, color: AppColors.accent),
                                Icon(Icons.star_border, size: 11, color: AppColors.accent),
                              ],
                            ),
                            value: data.saves,
                            label: 'Saves',
                            scale: s,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: ShieldPhoto(data: data, scale: s)),
          ),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name, required this.scale});

  final String name;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    Widget line() => Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 2.7 * s,
              constraints: BoxConstraints(maxWidth: 40 * s),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        line(),
        SizedBox(width: 16 * s),
        Flexible(
          flex: 3,
          child: Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 20 * s,
              fontWeight: FontWeight.w600,
              letterSpacing: 2 * s,
              height: 1.5,
              color: AppColors.white,
            ),
          ),
        ),
        SizedBox(width: 16 * s),
        line(),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label, required this.scale});

  final Widget icon;
  final int value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      decoration: BoxDecoration(color: _tileEdge, borderRadius: BorderRadius.circular(20 * s)),
      child: Container(
        margin: EdgeInsets.only(bottom: 3.3 * s),
        padding: EdgeInsets.fromLTRB(4 * s, 10 * s, 4 * s, 9 * s),
        decoration: BoxDecoration(color: _tileFill, borderRadius: BorderRadius.circular(20 * s)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44 * s,
              height: 44 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: IconTheme(data: IconThemeData(size: 24 * s), child: icon),
            ),
            SizedBox(height: 3.3 * s),
            Text(
              '$value',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 24 * s,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.accent,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16 * s,
                height: 1.15,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PAS | DRI | SHO | DEF | PAC | PHY averages.
class RatingsStrip extends StatelessWidget {
  const RatingsStrip({super.key, required this.data, required this.scale});

  final TrackerData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final cells = <(String, int)>[
      ('PAS', data.passing),
      ('DRI', data.dribbling),
      ('SHO', data.shooting),
      ('DEF', data.defending),
      ('PAC', data.pace),
      ('PHY', data.physicality),
    ];
    return Semantics(
      container: true,
      label: 'Average ratings: ${cells.map((c) => '${c.$1} ${c.$2}').join(', ')}',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.3 * s),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              for (var i = 0; i < cells.length; i++) ...<Widget>[
                if (i > 0)
                  Container(width: 1.2, height: 40 * s, color: const Color(0xFF7C888C)),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        cells[i].$1,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        '${cells[i].$2}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24 * s,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Year tabs ("2026") with the green underline.
class YearTabs extends StatelessWidget {
  const YearTabs({super.key, required this.years, required this.selected, required this.onChanged, required this.scale});

  final List<int> years;
  final int selected;
  final ValueChanged<int> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final y in years)
              Semantics(
                button: true,
                selected: y == selected,
                label: '$y',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(y),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18 * s),
                          child: ExcludeSemantics(
                            child: Text(
                              '$y',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16 * s,
                                height: 1.5,
                                color: y == selected ? AppColors.accent : AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 7.3 * s),
                        Container(
                          height: 2.7 * s,
                          color: y == selected ? AppColors.accent : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
