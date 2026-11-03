import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';
import 'package:ecoach_pro/features/skills/domain/repositories/skills_repository.dart';

class ApiSkillsRepository implements SkillsRepository {
  ApiSkillsRepository(this._api);

  final ApiService _api;

  @override
  Future<ApiResponse<List<SkillCategory>>> fetchCategories() =>
      _api.getSkillTypes();

  @override
  Future<ApiResponse<List<Drill>>> fetchDrills(int categoryId) =>
      _api.getSkillVideos(categoryId);

  @override
  Future<ApiResponse<List<Drill>>> fetchAllDrills() async {
    final cats = await _api.getSkillTypes();
    if (!cats.success) {
      return ApiResponse<List<Drill>>(
        success: false,
        message: cats.message,
        statusCode: cats.statusCode,
      );
    }

    final results = await Future.wait(
      (cats.data ?? const <SkillCategory>[]).map((c) => _api.getSkillVideos(c.id)),
    );

    final all = <Drill>[];
    final seen = <int>{};
    for (final r in results) {
      if (!r.success) return r; // includes "Subscription required"
      for (final d in r.data ?? const <Drill>[]) {
        if (seen.add(d.id)) all.add(d);
      }
    }
    return ApiResponse<List<Drill>>(success: true, message: '', data: all);
  }

  @override
  Future<ApiResponse<Drill>> fetchDrill(int drillId) =>
      _api.getSkillVideoDetails(drillId);

  @override
  Future<ApiResponse<void>> markCompleted(int drillId) =>
      _api.markSkillVideoCompleted(drillId);

  @override
  Future<ApiResponse<void>> setInPersonalSession(int drillId, {required bool add}) =>
      _api.setVideoInPersonalSession(drillId, add: add);

  @override
  Future<ApiResponse<void>> setInMySkills(int drillId, {required bool add}) =>
      _api.setVideoInMySkills(drillId, add: add);

  @override
  Future<ApiResponse<List<SkillNote>>> fetchNotes(int drillId) =>
      _api.getSkillNotes(drillId);

  @override
  Future<ApiResponse<void>> addNote(int drillId, String note) =>
      _api.addSkillNote(drillId, note);

  @override
  Future<ApiResponse<void>> updateNote(int noteId, String note) =>
      _api.updateSkillNote(noteId, note);

  @override
  Future<ApiResponse<void>> deleteNote(int noteId) =>
      _api.deleteSkillNote(noteId);
}
