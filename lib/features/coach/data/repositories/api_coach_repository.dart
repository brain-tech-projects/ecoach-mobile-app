import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/network/api_guard.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/coach/domain/entities/coach_entities.dart';
import 'package:ecoach_pro/features/coach/domain/repositories/coach_repository.dart';

class ApiCoachRepository implements CoachRepository {
  ApiCoachRepository(this._api);

  final ApiService _api;

  static int _id(String id) => int.tryParse(id) ?? 0;

  @override
  Future<Coach?> fetchConnectedCoach() async {
    final check = requireSuccess(await _api.checkCoachConnection());
    final data = check.data;
    final connected = data is Map && data['is_connected'] == true;
    if (!connected) return null;

    final res = requireSuccess(await _api.getConnectedCoaches());
    final body = res.data;
    final list = body is Map ? body['connections'] : null;
    if (list is! List || list.isEmpty || list.first is! Map) return null;

    final c = Map<String, dynamic>.from(list.first as Map);
    return Coach(
      id: '${c['coach_id']}',
      name: (c['full_name'] ?? '').toString(),
      team: (c['my_club'] ?? '').toString(),
      avatarUrl: Env.skillMediaUrl(c['profile_photo'] as String?),
    );
  }

  @override
  Future<void> disconnect(String coachId) async {
    requireSuccess(await _api.disconnectCoach(_id(coachId)));
  }

  @override
  Future<List<AssignedTraining>> fetchAssignedTrainings() async {
    final res = requireSuccess(await _api.getAllocatedTrainings());
    final data = res.data;
    if (data is! List) return const <AssignedTraining>[];

    return <AssignedTraining>[
      for (final e in data.whereType<Map>())
        AssignedTraining(
          id: '${e['id']}',
          title: _firstText(<Object?>[e['training_name'], e['video_title']]),
          videoUrl: ('${e['video_path'] ?? ''}').replaceAll(' ', '%20'),
        ),
    ];
  }

  static String _firstText(List<Object?> values) {
    for (final v in values) {
      final t = (v ?? '').toString().trim();
      if (t.isNotEmpty) return t;
    }
    return 'Training';
  }

  @override
  Future<void> completeTraining(String trainingId) async {
    requireSuccess(await _api.completeAllocatedTraining(_id(trainingId)));
  }

  @override
  Future<String> inviteCoach(String email) async {
    final res = requireSuccess(await _api.sendInvitationToCoach(email));
    return res.message.isEmpty ? 'Invitation sent.' : res.message;
  }
}
