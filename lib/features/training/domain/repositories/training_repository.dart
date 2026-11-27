import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Source of training content (the API one is `ApiTrainingRepository`).
abstract interface class TrainingRepository {
  Future<ApiResponse<TrainingOverview>> fetchLevels();

  Future<ApiResponse<List<TrainingVideo>>> fetchVideos(int levelId);

  /// Marks a level video as completed ("Training Complete").
  Future<ApiResponse<void>> completeVideo(int videoId);

  /// "Training Complete" page: current + next video.
  Future<ApiResponse<NextTrainingVideo>> fetchNextVideo(int videoId);

  /// "Training Complete" page: `/mark-video-completed`.
  /// `data` is the backend's `available_in` text ("2 days"), or null.
  Future<ApiResponse<String?>> markVideoCompleted(int videoId);
}
