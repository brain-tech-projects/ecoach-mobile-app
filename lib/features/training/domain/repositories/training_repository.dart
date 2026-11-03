import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Source of training content (the API one is `ApiTrainingRepository`).
abstract interface class TrainingRepository {
  Future<ApiResponse<TrainingOverview>> fetchLevels();

  Future<ApiResponse<List<TrainingVideo>>> fetchVideos(int levelId);
}
