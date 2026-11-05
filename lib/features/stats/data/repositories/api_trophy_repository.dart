import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/stats/domain/entities/trophy.dart';
import 'package:ecoach_pro/features/stats/domain/repositories/trophy_repository.dart';

class ApiTrophyRepository implements TrophyRepository {
  ApiTrophyRepository(this._api);

  final ApiService _api;

  double? _points;

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

  static const List<String> _months = <String>[
    'january', 'february', 'march', 'april', 'may', 'june', 'july',
    'august', 'september', 'october', 'november', 'december',
  ];

  /// "04 November 2026 01:10 PM"
  static DateTime _long(Object? v) {
    final m = RegExp(r'(\d{1,2}) (\w+) (\d{4}) (\d{1,2}):(\d{2}) ?(AM|PM)?', caseSensitive: false)
        .firstMatch('${v ?? ''}');
    if (m == null) return DateTime.now();
    var hour = int.parse(m.group(4)!) % 12;
    if ((m.group(6) ?? '').toUpperCase() == 'PM') hour += 12;
    final month = _months.indexOf(m.group(2)!.toLowerCase()) + 1;
    return DateTime(
      int.parse(m.group(3)!),
      month == 0 ? 1 : month,
      int.parse(m.group(1)!),
      hour,
      int.parse(m.group(5)!),
    );
  }

  @override
  Future<List<MyTrophy>> fetchMyTrophies() async {
    final res = requireSuccess(await _api.getRedeemHistory());
    final data = res.data;
    if (data is! List) return const <MyTrophy>[];

    return <MyTrophy>[
      for (final e in data.whereType<Map>())
        MyTrophy(
          trophy: Trophy(
            id: '',
            name: (e['trophy_title'] ?? '').toString(),
            points: (_num(e['points_spent']) ?? 0).round(),
            imageUrl: Env.skillMediaUrl(e['trophy_icon'] as String?),
          ),
          points: _num(e['points_spent']) ?? 0,
          redeemedAt: _long(e['redeemed_at']),
        ),
    ];
  }

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
    return res.message.isEmpty
        ? const RedeemResult.success()
        : RedeemResult.success(res.message);
  }
}
