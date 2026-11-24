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
  Future<List<CoachInvite>> fetchPendingInvitations() async {
    final res = requireSuccess(await _api.getMyInvitations());
    final body = res.data;
    final list = body is Map ? body['invitations'] : null;
    if (list is! List) return const <CoachInvite>[];
    return <CoachInvite>[
      for (final e in list.whereType<Map>())
        if ('${e['status'] ?? ''}'.toLowerCase() == 'pending' && e['coach'] is Map)
          CoachInvite(
            id: int.tryParse('${e['id']}') ?? 0,
            name: ('${(e['coach'] as Map)['full_name'] ?? ''}').trim(),
            subtitle: <String>[
              '${(e['coach'] as Map)['my_position'] ?? ''}',
              '${(e['coach'] as Map)['my_club'] ?? ''}',
            ].map((v) => v.trim()).where((v) => v.isNotEmpty).join(' . '),
            avatarUrl: Env.skillMediaUrl((e['coach'] as Map)['profile_photo'] as String?),
          ),
    ];
  }

  @override
  Future<String> respondInvitation(int invitationId, {required bool accept}) async {
    final res = requireSuccess(await _api.respondCoachInvitation(invitationId, accept: accept));
    if (res.message.isNotEmpty) return res.message;
    return accept ? 'Invitation accepted.' : 'Invitation rejected.';
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
          description: _plain(<Object?>[e['description'], e['training_description'], e['video_description'], e['notes']]),
          topTip: _plain(<Object?>[e['top_tip'], e['tip']]),
          instructions: _points(<Object?>[e['instructions'], e['key_points'], e['steps'], e['bullets']]),
        ),
    ];
  }

  static String _clean(Object? v) => (v is List ? v.join('\n') : (v ?? '').toString())
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*(li|p|div)\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&');

  /// First non-empty value as one tidy line.
  static String _plain(List<Object?> values) {
    for (final v in values) {
      final t = _clean(v).replaceAll(RegExp(r'\s+'), ' ').trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  /// First non-empty list / multi-line text as bullet points.
  static List<String> _points(List<Object?> values) {
    for (final v in values) {
      final items = v is List ? v : <Object?>[v];
      final out = <String>[
        for (final item in items)
          for (final line in _clean(item).split(RegExp(r'[\r\n]+')))
            if (line.replaceFirst(RegExp(r'^[\s•·\-\*]+'), '').trim().isNotEmpty)
              line.replaceFirst(RegExp(r'^[\s•·\-\*]+'), '').replaceAll(RegExp(r'\s+'), ' ').trim(),
      ];
      if (out.isNotEmpty) return out;
    }
    return const <String>[];
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
