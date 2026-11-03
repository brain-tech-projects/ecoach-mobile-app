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
}
