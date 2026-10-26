import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/training/domain/entities/training_entities.dart';
import 'package:ecoach_pro/features/training/domain/repositories/training_repository.dart';

/// Static demo content (replace with the API-backed repository later).
class DummyTrainingRepository implements TrainingRepository {
  static const String _sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Future<List<TrainingLevel>> fetchLevels() async => const <TrainingLevel>[
    TrainingLevel(
      id: 'fundamentals',
      title: 'FUNDAMENTALS',
      unlocked: 1,
      total: 23,
      imageAsset: AppAssets.trainingTile,
    ),
  ];

  @override
  Future<List<TrainingVideo>> fetchVideos(String levelId) async =>
      List<TrainingVideo>.generate(
        23,
        (i) => TrainingVideo(
          id: '$levelId-${i + 1}',
          title: 'Fundamental #${i + 1}',
          videoUrl: _sampleVideo,
        ),
      );
}
