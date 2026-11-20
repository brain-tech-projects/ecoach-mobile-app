import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/features/auth/data/countries_data.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';

/// Dropdown-style field showing the selected country (flag + name + chevron).
class CountryField extends StatelessWidget {
  const CountryField({
    super.key,
    required this.country,
    required this.onTap,
    required this.scale,
  });

  final Country country;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Semantics(
      button: true,
      label: 'Country, ${country.name}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 51.3 * s,
            padding: EdgeInsets.only(left: 15 * s, right: 6.7 * s),
            decoration: BoxDecoration(
              color: AppColors.countryFill,
              border: Border.all(color: AppColors.countryBorder),
              borderRadius: BorderRadius.circular(11.5 * s),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 18 * s,
                  child: CountryFlag(country: country, size: 15 * s),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    country.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.countryValue.scaled(s),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 24 * s,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Searchable bottom sheet listing all countries. Returns the chosen one.
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({
    super.key,
    required this.selected,
    required this.scale,
  });

  final Country selected;
  final double scale;

  static Future<Country?> show(
    BuildContext context, {
    required Country selected,
    required double scale,
  }) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      builder: (_) => CountryPickerSheet(selected: selected, scale: scale),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  /// Lower-case, accent-free text so "cote" finds "Côte d'Ivoire".
  static String _fold(String v) {
    const from = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
    const to = 'aaaaaaceeeeiiiinooooouuuuyy';
    final b = StringBuffer();
    for (final ch in v.toLowerCase().split('')) {
      final k = from.indexOf(ch);
      b.write(k == -1 ? ch : to[k]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final q = _fold(_query.trim());
    final items = Countries.all
        .where((c) => _fold(c.name).contains(q))
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      // SafeArea keeps the list clear of the Android 3-button / gesture bar
      // and the iOS home indicator.
      child: SafeArea(
        top: false,
        child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: <Widget>[
            SizedBox(height: 12 * s),
            Container(
              width: 40 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                color: AppColors.checkboxBorder,
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22 * s, 16 * s, 22 * s, 8 * s),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                cursorColor: AppColors.accent,
                style: AppTextStyles.fieldText.scaled(s),
                decoration: InputDecoration(
                  hintText: 'Search country',
                  hintStyle: AppTextStyles.fieldHint.scaled(s),
                  prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  contentPadding: EdgeInsets.symmetric(vertical: 12 * s),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11 * s),
                    borderSide: const BorderSide(color: AppColors.fieldBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11 * s),
                    borderSide: const BorderSide(color: AppColors.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11 * s),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final c = items[index];
                  final isSelected = c == widget.selected;
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(c),
                    contentPadding: EdgeInsets.symmetric(horizontal: 22 * s),
                    leading: CountryFlag(country: c, size: 22 * s),
                    title: Text(
                      c.name,
                      style: AppTextStyles.countryValue.scaled(s),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.accent)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Flag of a country. Flag emoji for everything, except Northern Ireland which
/// has no emoji flag, so its banner is drawn.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.country, required this.size});

  final Country country;

  /// Font size of the emoji (the drawn flag is scaled to match).
  final double size;

  @override
  Widget build(BuildContext context) {
    if (country == Countries.northernIreland) {
      return Align(
        alignment: Alignment.centerLeft,
        child: CustomPaint(
          size: Size(size * 1.2, size * 0.85),
          painter: const _NorthernIrelandFlagPainter(),
        ),
      );
    }
    return Text(
      country.flag,
      maxLines: 1,
      style: TextStyle(fontSize: size, height: 1.2),
    );
  }
}

/// Simplified Ulster Banner: red cross on white, with a red-ringed centre.
class _NorthernIrelandFlagPainter extends CustomPainter {
  const _NorthernIrelandFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height * 0.12),
    );
    canvas.save();
    canvas.clipRRect(rect);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));

    final red = Paint()..color = const Color(0xFFC8102E);
    final arm = size.height * 0.24;
    canvas.drawRect(
      Rect.fromLTWH(0, (size.height - arm) / 2, size.width, arm),
      red,
    );
    canvas.drawRect(
      Rect.fromLTWH((size.width - arm) / 2, 0, arm, size.height),
      red,
    );

    final c = size.center(Offset.zero);
    canvas.drawCircle(c, size.height * 0.26, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(
      c,
      size.height * 0.26,
      Paint()
        ..color = const Color(0xFFC8102E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.07,
    );
    canvas.drawCircle(c, size.height * 0.09, red);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
