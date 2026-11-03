/// `GET /details` - numbers shown in "Your Stats" and "Keep Going".
class DashboardDetails {
  const DashboardDetails({
    this.trackers = 0,
    this.trophies = 0,
    this.points = 0,
    this.streak = 0,
    this.monthlyPoints = 0,
  });

  final int trackers;
  final int trophies;
  final double points;
  final int streak;
  final double monthlyPoints;

  factory DashboardDetails.fromJson(Map<String, dynamic> json) =>
      DashboardDetails(
        trackers: _int(json['trackers']),
        trophies: _int(json['trophies']),
        points: _num(json['points']),
        streak: _int(json['streak']),
        monthlyPoints: _num(json['monthlyPoints']),
      );

  static int _int(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

  static double _num(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;
}
