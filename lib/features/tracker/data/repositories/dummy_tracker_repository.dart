import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';

/// In-memory demo data (kept for the whole app session).
class DummyTrackerRepository implements TrackerRepository {
  final List<MatchEntry> _entries = <MatchEntry>[
    MatchEntry(
      id: 'm1', opponent: 'RCB', playedOn: DateTime(2026, 1, 27), score: 'W 2-1',
      passing: 10, dribbling: 10, shooting: 10, defending: 10, pace: 10,
      physicality: 5, assists: 4, goals: 56, saves: 4,
    ),
    MatchEntry(
      id: 'm2', opponent: 'CSK', playedOn: DateTime(2026, 1, 27), score: 'L 1-3',
      passing: 2, dribbling: 2, shooting: 4, defending: 4, pace: 6,
      physicality: 7, assists: 7, goals: 8, saves: 9,
    ),
  ];

  int _seq = 3;

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<ApiResponse<TrackerData>> fetchTracker() async {
    await _latency();
    final sorted = List<MatchEntry>.of(_entries)
      ..sort((a, b) => b.playedOn.compareTo(a.playedOn));
    return ApiResponse<TrackerData>(
      success: true,
      message: 'OK',
      data: TrackerData(
        playerName: 'Virat',
        photoAsset: 'assets/images/player/profile_avatar.png',
        entries: sorted,
      ),
    );
  }

  @override
  Future<ApiResponse<MatchEntry>> saveMatch(MatchEntry entry) async {
    await _latency();
    if (entry.id.isEmpty) {
      final saved = entry.copyWith(id: 'm${_seq++}');
      _entries.insert(0, saved);
      return ApiResponse<MatchEntry>(success: true, message: 'Saved', data: saved);
    }
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i < 0) {
      return const ApiResponse<MatchEntry>(success: false, message: 'Match not found');
    }
    _entries[i] = entry;
    return ApiResponse<MatchEntry>(success: true, message: 'Saved', data: entry);
  }

  @override
  Future<ApiResponse<void>> deleteMatch(String id) async {
    await _latency();
    _entries.removeWhere((e) => e.id == id);
    return const ApiResponse<void>(success: true, message: 'Deleted');
  }
}

/// Photo upload is not wired yet: explains it instead of failing silently.
class UnavailablePhotoPicker implements MatchPhotoPicker {
  @override
  Future<String?> pick() async {
    AppToast.info('Photo upload is not available yet');
    return null;
  }
}
