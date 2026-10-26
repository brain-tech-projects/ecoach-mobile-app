import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';

/// Source of training content. Swap the dummy implementation for the API one
/// in `TrainingBinding` when the backend is ready.
abstract interface class TrainingRepository {
  Future<List<TrainingLevel>> fetchLevels();

  Future<List<TrainingVideo>> fetchVideos(String levelId);
}
