import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/session_service.dart';
import 'package:ecoach_pro/features/ai_session/domain/ai_session_entities.dart';

void ensureAiSessionRepository() {
  if (!Get.isRegistered<AiSessionRepository>()) {
    Get.put<AiSessionRepository>(AiSessionRepository(), permanent: true);
  }
}

/// First name for "Hi Virat" (falls back to the dummy name).
String aiFirstName() {
  final user = Get.isRegistered<SessionService>() ? Get.find<SessionService>().user.value : null;
  final name = (user?.fullName ?? '').trim();
  return name.isEmpty ? 'Virat' : name.split(' ').first;
}

/// DUMMY in-memory source. Keep the signatures, swap the bodies for API calls.
class AiSessionRepository {
  static const String _video = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const String _img = 'assets/images/drills/';

  static const List<AiChip> chips = <AiChip>[
    AiChip('Dribbling', '⚡', 'I want to work on my dribbling.'),
    AiChip('First touch', '🎯', 'I want to work on my first touch.'),
    AiChip('Passing', '🔁', 'I want to work on my passing.'),
    AiChip('Shooting', '🥅', 'I want to work on my shooting.'),
    AiChip('Weaker foot', '🦶', 'I want to work on my weaker foot.'),
    AiChip('Speed', '💨', 'I want to work on my speed.'),
    AiChip('Match prep', '🏆', 'I have a match tomorrow and want to practise first touch.'),
  ];

  static const List<String> suggestions = <String>[
    'Help me beat players with better dribbling.',
    'Give me a session to improve my passing.',
    'I have a match tomorrow and want to practise first touch.',
    'I want to work on my dribbling, weaker foot and shooting.',
  ];

  static const AiProfile profile = AiProfile(
    age: '6 years old',
    positions: <String>['Defender', 'Goalkeeper'],
    levels: <String>['Just starting out', 'Confident player'],
    focus: <String>['Dribbling', 'Passing'],
  );

  static const List<AiDrill> _drills = <AiDrill>[
    AiDrill(
      id: 31,
      title: '#31 Vertical Throw, Outside Foot Control',
      category: 'Ball Control',
      description: 'Start by throwing the ball into the air, just before the ball lands take a touch with the outside of your stronger foot to pull the ball away. Adjust your position to the ball flight, ensure you are balanced. Relax your foot slightly as the ball makes contact.',
      note: 'Matches your request, your goal: passing, level: confident player, position: goalkeeper/defender',
      thumb: '${_img}drill_19.jpg',
      videoUrl: _video,
    ),
    AiDrill(
      id: 5,
      title: '#5 Step Overs (stronger foot)',
      category: 'Ball Mastery',
      description: 'Trace a big circle over the ball with your strong foot',
      note: 'Your goal: dribbling, your goal: passing, level: confident player, position: goalkeeper/defender',
      thumb: '${_img}drill_8.jpg',
      videoUrl: _video,
    ),
    AiDrill(
      id: 16,
      title: '#16 Ball Striking',
      category: 'Ball Control',
      description: 'Strike through the centre of the ball with your laces, keep your ankle locked and follow through towards your target.',
      note: 'Matches your request',
      thumb: '${_img}drill_12.jpg',
      videoUrl: _video,
    ),
    AiDrill(
      id: 10,
      title: '#10 Studs Forward',
      category: 'Ball Mastery',
      description: 'Roll the ball forward with the studs of your boot, stay balanced and keep light on your supporting foot.',
      note: 'Matches your request',
      thumb: '${_img}drill_13.jpg',
      videoUrl: _video,
    ),
  ];

  static const List<String> _pool = <String>[
    'I want to work on my first touch.',
    'Help me beat players with better dribbling.',
    'I want to work on my dribbling, weaker foot and shooting.',
    'Give me a session to improve my passing.',
    'I want to work on my speed.',
    'I have a match tomorrow and want to practise first touch.',
  ];

  final List<AiSessionSummary> _recent = <AiSessionSummary>[
    for (var i = 0; i < 17; i++)
      AiSessionSummary(id: i + 1, request: _pool[i % _pool.length], when: i == 0 ? 'Today' : (i < 3 ? '6 days ago' : '${i + 4} days ago')),
  ];

  Future<void> _lag([int ms = 300]) => Future<void>.delayed(Duration(milliseconds: ms));

  Future<List<AiSessionSummary>> fetchRecent() async {
    await _lag();
    return List<AiSessionSummary>.of(_recent);
  }

  AiSession _session(int id, String request) => AiSession(
    id: id,
    request: request,
    summary: 'I picked 4 drills focused on first touch, passing and skills & tricks, set for a just starting out player aged 6. Start with drill 1 and work your way through.',
    tags: const <String>['First touch', 'Passing', 'Skills & tricks'],
    drills: _drills,
  );

  /// Simulates the AI build.
  Future<AiSession> buildSession(String request) async {
    await _lag(600);
    final id = _recent.length + 1;
    _recent.insert(0, AiSessionSummary(id: id, request: request, when: 'Today'));
    return _session(id, request);
  }

  AiSession sessionFor(AiSessionSummary s) => _session(s.id, s.request);
}
