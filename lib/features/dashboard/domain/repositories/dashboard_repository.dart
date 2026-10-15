import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_data.dart';

/// Source of dashboard content. Swap [DummyDashboardRepository] for an API
/// implementation in `DashboardBinding` when the backend is ready.
abstract interface class DashboardRepository {
  Future<DashboardData> fetchDashboard();
}
