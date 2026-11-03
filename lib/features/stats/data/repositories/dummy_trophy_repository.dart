import 'package:ecoach_pro/features/stats/data/trophy_assets.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';

/// In-memory demo data (replace with an API-backed repository later).
/// Registered once as a singleton, so points and redeemed trophies survive
/// moving between the Trophy Room pages.
class DummyTrophyRepository implements TrophyRepository {
  double _points = 185;
  final List<MyTrophy> _mine = <MyTrophy>[];

  static const List<Trophy> _all = <Trophy>[
    Trophy(
      id: 'terrific-touch',
      name: 'Terrific Touch',
      points: 50,
      imageAsset: TrophyAssets.terrificTouch,
      detailAsset: TrophyAssets.terrificTouchDetail,
    ),
    Trophy(
      id: 'awesome-attitude',
      name: 'Awesome Attitude',
      points: 500,
      imageAsset: TrophyAssets.awesomeAttitude,
    ),
    Trophy(
      id: 'soccer-star',
      name: 'Soccer Star',
      points: 500,
      imageAsset: TrophyAssets.soccerStar,
    ),
    Trophy(
      id: 'energy-booster',
      name: 'Energy Booster',
      points: 500,
      imageAsset: TrophyAssets.energyBooster,
    ),
    Trophy(
      id: 'team-spirit',
      name: 'Team Spirit',
      points: 500,
      imageAsset: TrophyAssets.teamSpirit,
    ),
    Trophy(
      id: 'skills-slider',
      name: 'Skills Slider',
      points: 750,
      imageAsset: TrophyAssets.skillsSlider,
    ),
    // No art yet: a placeholder is drawn until the API sends images.
    Trophy(id: 'mega-stopper', name: 'Mega Stopper', points: 750),
    Trophy(id: 'midfield-maestro', name: 'Midfield Maestro', points: 750),
  ];

  @override
  Future<double> fetchPoints() async => _points;

  @override
  Future<List<Trophy>> fetchTrophies() async => _all;

  @override
  Future<List<MyTrophy>> fetchMyTrophies() async =>
      List<MyTrophy>.unmodifiable(_mine);

  @override
  Future<RedeemResult> redeem(Trophy trophy) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_mine.any((m) => m.trophy.id == trophy.id)) {
      return const RedeemResult.failure('Trophy already redeemed');
    }
    if (_points < trophy.points) {
      return const RedeemResult.failure(
        'Not enough points to redeem this trophy',
      );
    }
    _points -= trophy.points;
    _mine.insert(
      0,
      MyTrophy(
        trophy: trophy,
        points: trophy.points.toDouble(),
        redeemedAt: DateTime.now(),
      ),
    );
    return const RedeemResult.success();
  }
}
