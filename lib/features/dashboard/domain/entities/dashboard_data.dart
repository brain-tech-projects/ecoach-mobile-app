import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/program.dart';

@immutable
class DashboardData {
  const DashboardData({required this.stats, required this.programs});

  final List<DashboardStat> stats;
  final List<Program> programs;
}
