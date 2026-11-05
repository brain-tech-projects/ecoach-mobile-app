import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';

class ApiTrophyRepository implements TrophyRepository {
  ApiTrophyRepository(this._api);

  final ApiService _api;

  double? _points;
  final List<MyTrophy> _redeemed = <MyTrophy>[];

  static double? _num(Object? v) =>
      v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

  @override
  Future<double> fetchPoints() async {
    if (_points != null) return _points!;
    // /trophies sends `user_points` (sometimes null): fall back to /details.
    final res = await _api.getDetails();
    requireSuccess(res);
    return _points = res.data?.points ?? 0;
  }

  @override
  Future<List<Trophy>> fetchTrophies() async {
    final res = requireSuccess(await _api.getTrophies());
    final fromApi = _num(res.body?['user_points']);
    if (fromApi != null) _points = fromApi;

    final data = res.data;
    if (data is! List) return const <Trophy>[];
    return <Trophy>[
      for (final e in data.whereType<Map>())
        Trophy(
          id: '${e['id']}',
          name: (e['title'] ?? '').toString(),
          points: int.tryParse('${e['points_needed'] ?? 0}') ?? 0,
          imageUrl: Env.skillMediaUrl(e['icon'] as String?),
        ),
    ];
  }

  /// TODO(api): there is no "my trophies" endpoint yet; this list only holds
  /// the trophies redeemed since the app was opened.
  @override
  Future<List<MyTrophy>> fetchMyTrophies() async =>
      List<MyTrophy>.unmodifiable(_redeemed.reversed);

  @override
  Future<RedeemResult> redeem(Trophy trophy) async {
    final res = await _api.redeemTrophy(int.tryParse(trophy.id) ?? 0);
    if (res.isSubscriptionRequired) {
      try {
        requireSuccess(res);
      } on ApiException catch (e) {
        return RedeemResult.failure(e.message);
      }
    }
    if (!res.success) return RedeemResult.failure(res.message);

    final left = _num(res.body?['user_points']);
    if (left != null) _points = left;
    _redeemed.add(
      MyTrophy(
        trophy: trophy,
        points: trophy.points.toDouble(),
        redeemedAt: DateTime.now(),
      ),
    );
    return res.message.isEmpty
        ? const RedeemResult.success()
        : RedeemResult.success(res.message);
  }
}
