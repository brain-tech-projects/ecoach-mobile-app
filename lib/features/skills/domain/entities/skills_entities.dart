import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';

int _int(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

/// "Top Tip: ...\r\n\r\nFocus: ..." -> one tidy line of text.
String _oneLine(Object? v) => (v ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

String _join(Object? v) => v is List ? v.map((e) => e.toString()).join(', ') : '';

/// A skill area (Dribbling, Ball Mastery...) from `GET /skill-types`.
@immutable
class SkillCategory {
  const SkillCategory({required this.id, required this.name, this.imageUrl, this.imageAsset});

  /// Static tile at the end of the grid: every drill of every skill area.
  static const SkillCategory all = SkillCategory(id: 0, name: 'All Skills', imageAsset: AppAssets.skillAllSkills);

  factory SkillCategory.fromJson(Map<String, dynamic> json) =>
      SkillCategory(id: _int(json['id']), name: (json['name'] ?? '').toString(), imageUrl: Env.skillMediaUrl(json['image'] as String?));

  final int id;
  final String name;
  final String? imageUrl;

  /// Bundled image (only the static All Skills tile).
  final String? imageAsset;

  bool get isAll => id == 0;

  /// "What's New & Open Access" (free drills, opened from Home).
  static const SkillCategory openAccess = SkillCategory(id: -1, name: 'My Skills');

  bool get isOpenAccess => id == -1;
}

/// A skill video ("drill"). The list API fills the first fields; the details
/// API adds [videoUrl], [points], [focus], [equipment] and [completed].
@immutable
class Drill {
  const Drill({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail = '',
    this.videoUrl = '',
    this.focus = '',
    this.equipment = '',
    this.views = 0,
    this.points = 0,
    this.completed = false,
    this.isFree = false,
    this.canAddToSession = true,
    this.canAddToMySkills = true,
    this.thumbnailAspect = 327 / 280,
  });

  factory Drill.fromJson(Map<String, dynamic> json) => Drill(
    id: _int(json['id']),
    title: (json['title'] ?? '').toString(),
    description: _oneLine(json['description']),
    thumbnail: Env.skillMediaUrl(json['image'] as String?) ?? '',
    videoUrl: Env.skillMediaUrl(json['video'] as String?) ?? '',
    focus: _join(json['categories']),
    equipment: _join(json['equipment_items']),
    views: _int(json['views']),
    points: _int(json['reward_points']),
    completed: json['completed'] == true,
    isFree: json['is_free'] == true,
    // `true` = the option is offered (not added yet).
    canAddToSession: json['addToPersonalTrainingSession'] != false,
    canAddToMySkills: json['addToMySkills'] != false,
  );

  final int id;
  final String title; // e.g. "#8 Dribble and Turn"
  final String description;
  final String thumbnail; // https URL ('' when none)
  final String videoUrl;
  final String focus;
  final String equipment;
  final int views;
  final int points;
  final bool completed;
  final bool isFree;

  /// Menu state: true = "Add to ...", false = already added ("Remove ...").
  final bool canAddToSession;
  final bool canAddToMySkills;

  /// width / height of the list thumbnail.
  final double thumbnailAspect;

  /// This drill with the details-API values (keeps the list thumbnail).
  Drill withDetails(Drill d) => Drill(
    id: id,
    title: d.title.isEmpty ? title : d.title,
    description: d.description.isEmpty ? description : d.description,
    thumbnail: thumbnail.isEmpty ? d.thumbnail : thumbnail,
    videoUrl: d.videoUrl,
    focus: d.focus,
    equipment: d.equipment,
    views: d.views,
    points: d.points,
    completed: d.completed,
    isFree: d.isFree,
    canAddToSession: d.canAddToSession,
    canAddToMySkills: d.canAddToMySkills,
    thumbnailAspect: thumbnailAspect,
  );

  Drill copyWith({bool? completed, bool? canAddToSession, bool? canAddToMySkills}) => Drill(
    id: id,
    title: title,
    description: description,
    thumbnail: thumbnail,
    videoUrl: videoUrl,
    focus: focus,
    equipment: equipment,
    views: views,
    points: points,
    completed: completed ?? this.completed,
    isFree: isFree,
    canAddToSession: canAddToSession ?? this.canAddToSession,
    canAddToMySkills: canAddToMySkills ?? this.canAddToMySkills,
    thumbnailAspect: thumbnailAspect,
  );
}

/// A note the user wrote on a drill (`/get-skill-notes`).
@immutable
class SkillNote {
  const SkillNote({required this.id, required this.text, required this.createdAt});

  factory SkillNote.fromJson(Map<String, dynamic> json) => SkillNote(
    id: _int(json['id']),
    text: (json['note'] ?? '').toString(),
    createdAt: DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal() ?? DateTime.now(),
  );

  final int id;
  final String text;
  final DateTime createdAt;
}
