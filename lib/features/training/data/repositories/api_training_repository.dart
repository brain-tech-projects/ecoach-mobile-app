import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

class ApiTrainingRepository implements TrainingRepository {
  ApiTrainingRepository(this._api);

  final ApiService _api;

  @override
  Future<ApiResponse<TrainingOverview>> fetchLevels() =>
      _api.getTrainingTypes();

  @override
  Future<ApiResponse<List<TrainingVideo>>> fetchVideos(int levelId) =>
      _api.getTrainingVideos(levelId);

  @override
  Future<ApiResponse<void>> completeVideo(int videoId) =>
      _api.markTrainingVideoCompleted(videoId);

  @override
  Future<ApiResponse<NextTrainingVideo>> fetchNextVideo(int videoId) =>
      _api.getNextTrainingVideo(videoId);

  @override
  Future<ApiResponse<String?>> markVideoCompleted(int videoId) =>
      _api.markVideoCompleted(videoId);
}
