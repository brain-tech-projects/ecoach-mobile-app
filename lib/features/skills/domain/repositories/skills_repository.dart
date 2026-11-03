import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Source of skills content (the API one is `ApiSkillsRepository`).
abstract interface class SkillsRepository {
  Future<ApiResponse<List<SkillCategory>>> fetchCategories();

  Future<ApiResponse<List<Drill>>> fetchDrills(int categoryId);

  /// Every drill of every skill area (the static "All Skills" tile).
  Future<ApiResponse<List<Drill>>> fetchAllDrills();

  Future<ApiResponse<Drill>> fetchDrill(int drillId);

  Future<ApiResponse<void>> markCompleted(int drillId);

  Future<ApiResponse<void>> setInPersonalSession(int drillId, {required bool add});

  Future<ApiResponse<void>> setInMySkills(int drillId, {required bool add});

  Future<ApiResponse<List<SkillNote>>> fetchNotes(int drillId);

  Future<ApiResponse<void>> addNote(int drillId, String note);

  Future<ApiResponse<void>> updateNote(int noteId, String note);

  Future<ApiResponse<void>> deleteNote(int noteId);
}
