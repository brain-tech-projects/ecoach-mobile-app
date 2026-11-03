import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';

/// In-memory demo data (replace with an API-backed repository later).
/// Registered once as a singleton so "disconnect" is remembered by both pages.
class DummyCoachRepository implements CoachRepository {
  static const String _sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  Coach? _coach = const Coach(
    id: 'coach-1',
    name: 'Virat',
    team: 'RCB',
    avatarAsset: 'assets/images/coach/coach_avatar.png',
  );

  static const List<String> _titles = <String>[
    'My Training',
    '#3 Knees Up',
    '#8 Dribble and Turn',
    'Modernaee',
    'dasdasd',
    'yyyy',
    'training name',
    'erertt',
  ];

  @override
  Future<Coach?> fetchConnectedCoach() async => _coach;

  @override
  Future<void> disconnect(String coachId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _coach = null;
  }

  @override
  Future<List<AssignedTraining>> fetchAssignedTrainings() async {
    if (_coach == null) return const <AssignedTraining>[];
    return <AssignedTraining>[
      for (var i = 0; i < _titles.length; i++)
        AssignedTraining(
          id: 'assigned-$i',
          title: _titles[i],
          videoUrl: _sampleVideo,
        ),
    ];
  }

  @override
  Future<void> completeTraining(String trainingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
