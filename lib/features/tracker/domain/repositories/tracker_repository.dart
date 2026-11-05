import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/tracker/domain/entities/tracker_entities.dart';

/// Source of the Rating Tracker. `ApiTrackerRepository` can replace the dummy
/// in `ensureTrackerRepository()` (tracker_binding.dart).
abstract interface class TrackerRepository {
  Future<ApiResponse<TrackerData>> fetchTracker();

  /// Whether the "add match" button may be shown.
  Future<bool> canAddMatch();

  /// One match with its full details (opens the edit form).
  Future<ApiResponse<MatchEntry>> fetchMatch(String id);

  /// Creates ([MatchEntry.id] empty) or updates a match. A local
  /// [MatchEntry.photoPath] has to be uploaded by the implementation.
  Future<ApiResponse<MatchEntry>> saveMatch(MatchEntry entry);

  Future<ApiResponse<void>> deleteMatch(String id);
}

/// Lets the user choose a photo for a match. Return the local file path, or
/// null when cancelled. The default implementation tells the user that photo
/// upload is unavailable (add `image_picker` and register your own).
abstract interface class MatchPhotoPicker {
  Future<String?> pick();
}
