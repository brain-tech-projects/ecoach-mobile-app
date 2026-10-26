import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Source of skills content. Swap the dummy implementation for the API one in
/// `SkillsBinding` when the backend is ready.
abstract interface class SkillsRepository {
  Future<List<SkillCategory>> fetchCategories();

  Future<List<Drill>> fetchDrills(String categoryId);
}
