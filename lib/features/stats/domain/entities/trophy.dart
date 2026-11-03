import 'package:flutter/foundation.dart';

/// A trophy that can be redeemed with reward points.
///
/// Art: [imageAsset] (square thumbnail), optional [detailAsset] (wide hero
/// image) or [imageUrl] once the API provides images.
@immutable
class Trophy {
  const Trophy({
    required this.id,
    required this.name,
    required this.points,
    this.imageAsset,
    this.detailAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int points;
  final String? imageAsset;
  final String? detailAsset;
  final String? imageUrl;
}

/// A trophy the player has already redeemed ("My Trophies").
@immutable
class MyTrophy {
  const MyTrophy({
    required this.trophy,
    required this.points,
    required this.redeemedAt,
  });

  final Trophy trophy;

  /// Points spent on it.
  final double points;
  final DateTime redeemedAt;

  /// "03 November 2026 10:56 AM"
  String get redeemedLabel {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    final d = redeemedAt;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    String two(int v) => v.toString().padLeft(2, '0');
    final suffix = d.hour < 12 ? 'AM' : 'PM';
    return '${two(d.day)} ${months[d.month - 1]} ${d.year} '
        '${two(hour12)}:${two(d.minute)} $suffix';
  }
}

/// Outcome of a redeem request ([message] is shown in a toast).
@immutable
class RedeemResult {
  const RedeemResult.success([this.message = 'Trophy redeemed successfully'])
      : success = true;
  const RedeemResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}
