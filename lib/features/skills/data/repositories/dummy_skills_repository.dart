import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

/// Static demo content (replace with the API-backed repository later).
class DummySkillsRepository implements SkillsRepository {
  static const String _sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Future<List<SkillCategory>> fetchCategories() async => const <SkillCategory>[
    SkillCategory(id: 'dribbling', name: 'Dribbling', imageAsset: AppAssets.skillDribbling),
    SkillCategory(id: 'ball-mastery', name: 'Ball Mastery', imageAsset: AppAssets.skillBallMastery),
    SkillCategory(id: 'fitness', name: 'Fitness', imageAsset: AppAssets.skillFitness),
    SkillCategory(id: 'ball-control', name: 'Ball Control', imageAsset: AppAssets.skillBallControl),
    SkillCategory(id: 'tricks', name: 'Tricks', imageAsset: AppAssets.skillTricks),
    SkillCategory(id: 'all-skills', name: 'All Skills', imageAsset: AppAssets.skillAllSkills),
  ];

  /// The same demo drills are returned for every category.
  @override
  Future<List<Drill>> fetchDrills(String categoryId) async => const <Drill>[
    Drill(
      id: '8',
      title: '#8 Dribble and Turn',
      description:
          'Top Tip: Use quick touches  Focus: Dribbling Equipment: Football '
          'From your starting position dribble 4 or 5 paces then use the sole '
          'of your foot to stop the ball dead and turn to the opposite '
          'direction. Build up the pace as you get more confident. Keep '
          'practicing!',
      focus: 'Use quick, light touches in this skill',
      equipment: 'Ball',
      views: 31,
      thumbnail: AppAssets.drill8,
      thumbnailAspect: 327 / 280,
      videoUrl: _sampleVideo,
      posterAsset: AppAssets.posterDribbleTurn,
    ),
    Drill(
      id: '11',
      title: '#11 Inside Foot Dribble',
      description:
          'Top Tip: Keep your head up and look around as you dribble. Focus: '
          'Dribbling Equipment: Football',
      focus: 'Keep your head up while dribbling',
      equipment: 'Ball',
      views: 11,
      thumbnail: AppAssets.drill11,
      thumbnailAspect: 327 / 324,
      videoUrl: _sampleVideo,
    ),
    Drill(
      id: '12',
      title: '#12 Dribbling: Inside to outside',
      description: 'Top Tip: Use both feet Focus: Dribbling Equipment: Football',
      focus: 'Use both feet',
      equipment: 'Ball',
      views: 7,
      thumbnail: AppAssets.drill12,
      thumbnailAspect: 327 / 323,
      videoUrl: _sampleVideo,
    ),
    Drill(
      id: '13',
      title: '#13 Step Overs: Changing Feet',
      description: 'Top Tip: Balance and smooth movement Focus: Dribbling Equipment: Football',
      focus: 'Stay balanced as you change feet',
      equipment: 'Ball',
      views: 6,
      thumbnail: AppAssets.drill13,
      thumbnailAspect: 327 / 279,
      videoUrl: _sampleVideo,
    ),
    Drill(
      id: '15',
      title: '#15 Step Overs',
      description: 'Top tip: Keep the ball under control Focus: Dribbling Equipment: Football',
      focus: 'Keep the ball under control',
      equipment: 'Ball',
      views: 4,
      thumbnail: AppAssets.drill15,
      thumbnailAspect: 327 / 279,
      videoUrl: _sampleVideo,
    ),
    Drill(
      id: '19',
      title: '#19 Dribble: Outside of foot (stronger foot)',
      description: 'Top tip: Keep touches light and close Focus: Dribbling Equipment: Football',
      focus: 'Keep your touches light',
      equipment: 'Ball',
      views: 6,
      thumbnail: AppAssets.drill19,
      thumbnailAspect: 327 / 275,
      videoUrl: _sampleVideo,
    ),
  ];
}
