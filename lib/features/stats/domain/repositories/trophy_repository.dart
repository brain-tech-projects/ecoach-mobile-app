import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';

abstract interface class TrophyRepository {
  /// Current reward points of the player.
  Future<double> fetchPoints();

  /// Every trophy in the Trophy Room.
  Future<List<Trophy>> fetchTrophies();

  /// Trophies the player redeemed already (newest first).
  Future<List<MyTrophy>> fetchMyTrophies();

  /// Spends points on [trophy]. Failures (already redeemed, not enough
  /// points, server errors) come back as [RedeemResult.failure].
  Future<RedeemResult> redeem(Trophy trophy);
}
