import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';

const Color aiTeal = Color(0xFF214B5A);
const Color aiPanel = Color(0xFF0B3743);
const Color aiRowFill = Color(0xFF364B51);

TextStyle aiText(double s, double size, {FontWeight w = FontWeight.w400, Color c = AppColors.white, double h = 1.4, FontStyle? style, TextDecoration? deco}) => TextStyle(
  fontFamily: AppTextStyles.fontFamily,
  fontSize: size * s,
  fontWeight: w,
  color: c,
  height: h,
  fontStyle: style,
  decoration: deco,
  decorationColor: c,
);

/// Green glowing sparkle circle ("eCoach AI").
class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(center: Alignment(-0.3, -0.4), colors: <Color>[Color(0xFF8CFF8F), Color(0xFF2FBF3A)]),
      boxShadow: <BoxShadow>[BoxShadow(color: AppColors.accent.withValues(alpha: 0.45), blurRadius: size * 0.5, spreadRadius: -size * 0.05)],
    ),
    child: Icon(Icons.auto_awesome, color: AppColors.black, size: size * 0.5),
  );
}

class AiTag extends StatelessWidget {
  const AiTag({super.key, required this.label, required this.scale, this.icon, this.size = 15});
  final String label;
  final double scale;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 7 * s),
      decoration: BoxDecoration(color: aiTeal, borderRadius: BorderRadius.circular(40 * s)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[Icon(icon, size: (size + 3) * s, color: AppColors.white), SizedBox(width: 6 * s)],
          Flexible(child: Text(label, style: aiText(s, size, w: FontWeight.w500))),
        ],
      ),
    );
  }
}

/// "✦ Matches your request ..." (green, sparkle at the left).
class AiNote extends StatelessWidget {
  const AiNote({super.key, required this.text, required this.scale, this.size = 14});
  final String text;
  final double scale;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 4 * s), child: Icon(Icons.auto_awesome, size: 13 * s, color: AppColors.accent)),
        SizedBox(width: 8 * s),
        Expanded(child: Text(text, style: aiText(s, size, c: const Color(0xFF7DF58A), h: 1.45))),
      ],
    );
  }
}

class AiCard extends StatelessWidget {
  const AiCard({super.key, required this.child, required this.scale, this.padding});
  final Widget child;
  final double scale;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(17 * s),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24 * s), border: Border.all(color: AppColors.cardBorder)),
      child: child,
    );
  }
}

class AiShieldNote extends StatelessWidget {
  const AiShieldNote({super.key, required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 14 * s),
      decoration: BoxDecoration(color: const Color(0xFF34524A), borderRadius: BorderRadius.circular(14 * s)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 3 * s), child: Icon(Icons.shield_outlined, size: 17 * s, color: const Color(0xFF7DF58A))),
          SizedBox(width: 12 * s),
          Expanded(child: Text('eCoach only uses drills from its approved training library.', style: aiText(s, 15, c: const Color(0xFF7DF58A)))),
        ],
      ),
    );
  }
}

/// Green-bordered pill button (Previous, Edit request, New session, New version).
class AiOutlineButton extends StatelessWidget {
  const AiOutlineButton({super.key, required this.label, required this.onTap, required this.scale, this.height = 50, this.enabled = true, this.fill});
  final String label;
  final VoidCallback? onTap;
  final double scale;
  final double height;
  final bool enabled;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = enabled ? AppColors.accent : AppColors.accent.withValues(alpha: 0.5);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: fill ?? Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: color, width: 1.5)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox(height: height * s, child: Center(child: Text(label, maxLines: 1, style: aiText(s, 17, w: FontWeight.w600, c: color)))),
          ),
        ),
      ),
    );
  }
}

/// Filled green pill with a leading icon ("▶ Open").
class AiFilledButton extends StatelessWidget {
  const AiFilledButton({super.key, required this.label, required this.onTap, required this.scale, this.icon, this.height = 50});
  final String label;
  final VoidCallback onTap;
  final double scale;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.accent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: SizedBox(
              height: height * s,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (icon != null) ...<Widget>[Icon(icon, size: 20 * s, color: AppColors.black), SizedBox(width: 4 * s)],
                  Text(label, style: aiText(s, 17, w: FontWeight.w600, c: AppColors.black)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drill row on the result screen: thumbnail + details.
class AiDrillCard extends StatelessWidget {
  const AiDrillCard({super.key, required this.drill, required this.number, required this.scale, required this.onTap});
  final AiDrill drill;
  final int number;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final long = drill.note.length > 30;
    return Semantics(
      button: true,
      label: 'Drill $number, ${drill.title}',
      child: Material(
        color: AppColors.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22 * s), side: const BorderSide(color: AppColors.cardBorder)),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 108 * s,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ExcludeSemantics(child: drill.thumb.startsWith('http') ? Image.network(drill.thumb, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF111C20))) : Image.asset(drill.thumb, fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF111C20)))),
                      Center(
                        child: Container(
                          width: 25 * s,
                          height: 25 * s,
                          decoration: const BoxDecoration(color: Color(0xCC2E6B3A), shape: BoxShape.circle),
                          child: Icon(Icons.play_arrow_rounded, size: 18 * s, color: AppColors.white),
                        ),
                      ),
                      Positioned(
                        left: 21 * s,
                        bottom: 14 * s,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20 * s)),
                          child: Text('${drill.mins} mins', style: aiText(s, 14, w: FontWeight.w600, c: AppColors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12 * s, 12 * s, 12 * s, 12 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 4 * s),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20 * s)),
                          child: Text('Drill $number', style: aiText(s, 14, w: FontWeight.w700, c: AppColors.black)),
                        ),
                        SizedBox(height: 6 * s),
                        Text(drill.title, style: aiText(s, 18, w: FontWeight.w500, h: 1.3)),
                        SizedBox(height: 8 * s),
                        Text('${drill.category} • ${drill.mins} mins', style: aiText(s, 15, c: AppColors.descGrey)),
                        SizedBox(height: 6 * s),
                        AiNote(text: long ? drill.note : drill.note, scale: s, size: long ? 14 : 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo orb with a rotating gradient ring.
class AiOrb extends StatefulWidget {
  const AiOrb({super.key, required this.size});
  final double size;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: <BoxShadow>[BoxShadow(color: AppColors.accent.withValues(alpha: 0.22), blurRadius: size * 0.22, spreadRadius: size * 0.02)]),
            ),
            RotationTransition(turns: _c, child: CustomPaint(size: Size.square(size), painter: _RingPainter())),
            Container(
              width: size * 0.66,
              height: size * 0.66,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(center: Alignment(-0.2, -0.5), radius: 0.95, colors: <Color>[Color(0xFFD4FFD0), Color(0xFF63F26E), Color(0xFF2DBF48)], stops: <double>[0, 0.45, 1]),
              ),
              child: Image.asset(AppAssets.logo, width: size * 0.4, errorBuilder: (_, _, _) => Icon(Icons.sports_soccer, size: size * 0.3, color: AppColors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width * 0.04;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: <Color>[Color(0x002BC9E8), Color(0xFF2BC9E8), Color(0xFF4AD82B), Color(0x004AD82B)],
        stops: <double>[0, 0.3, 0.7, 1],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(w / 2), 0, math.pi * 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Dotted spinner (active rows rotate, pending rows stay still).
class AiDots extends StatefulWidget {
  const AiDots({super.key, required this.size, required this.active});
  final double size;
  final bool active;

  @override
  State<AiDots> createState() => _AiDotsState();
}

class _AiDotsState extends State<AiDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant AiDots old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RotationTransition(turns: _c, child: CustomPaint(size: Size.square(widget.size), painter: _DotsPainter())),
  );
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - size.width * 0.08;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.35 + 0.65 * (i / 7));
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, size.width * (0.05 + 0.03 * (i / 7)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
