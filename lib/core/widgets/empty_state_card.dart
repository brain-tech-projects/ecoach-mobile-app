import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.scale,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.layers_outlined,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;
  final IconData icon;

  // Swap these for your AppColors tokens.
  static const Color _card = Color(0xFF0B1F20);
  static const Color _green = Color(0xFF22C55E);
  static const Color _iconBg = Color(0xFF123226);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 36 * s),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24 * s),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 76 * s,
            height: 76 * s,
            decoration: const BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: _green, size: 40 * s),
          ),
          SizedBox(height: 20 * s),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          if (subtitle != null) ...<Widget>[
            SizedBox(height: 8 * s),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * s,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            SizedBox(height: 20 * s),
            SizedBox(
              height: 36 * s,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 22 * s),
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600),
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}