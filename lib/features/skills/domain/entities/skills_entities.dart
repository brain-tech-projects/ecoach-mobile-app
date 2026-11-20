import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/core/config/env.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';

int _int(Object? v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

/// "Top Tip: ...\r\n\r\nFocus: ..." -> one tidy line of text.
String _oneLine(Object? v) => (v ?? '').toString().replaceAll(RegExp(r'\s+'), ' ').trim();

/// HTML (or plain text) -> plain text with one line break per block.
String _stripHtml(Object? v) {
  // A JSON list ("top_tip": ["Keep your head up"]) is joined, never printed
  // with its square brackets.
  var t = v is List
      ? v.map((e) => e is Map ? (e['text'] ?? e['title'] ?? e['name'] ?? '') : e).where((e) => '$e'.trim().isNotEmpty).join('\n')
      : (v ?? '').toString();
  if (t.isEmpty) return '';
  t = t
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*/\s*(li|p|div|ul|ol|h[1-6])\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
  return t;
}

/// First non-empty value among [keys] of [json] (as plain text).
String _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final t = _oneLine(_stripHtml(json[k]));
    if (t.isNotEmpty) return t;
  }
  return '';
}

/// The bullet list of the detail screen: a JSON list, or one text with a
/// line (or `<li>`) per point. Empty when the API sends none.
List<String> _bullets(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    final out = <String>[];
    if (v is List) {
      for (final e in v) {
        final raw = e is Map ? (e['text'] ?? e['title'] ?? e['description'] ?? e['name'] ?? '') : e;
        out.addAll(_splitPoints(raw));
      }
    } else if (v is String) {
      out.addAll(_splitPoints(v));
    }
    if (out.isNotEmpty) return out;
  }
  // Fallback: any other field whose name says it is a list of points / steps.
  for (final e in json.entries) {
    final k = e.key.toLowerCase();
    if (k.contains('reward') || k.contains('top_tip') || k.contains('categories') || k.contains('equipment')) continue;
    if (!(k.contains('instruction') || k.contains('point') || k.contains('step') || k.contains('bullet') || k.contains('detail'))) continue;
    if (e.value is! List && e.value is! String) continue;
    final out = <String>[];
    final v = e.value;
    if (v is List) {
      for (final x in v) {
        out.addAll(_splitPoints(x is Map ? (x['text'] ?? x['title'] ?? x['description'] ?? '') : x));
      }
    } else {
      out.addAll(_splitPoints(v));
    }
    if (out.isNotEmpty) return out;
  }
  return const <String>[];
}

List<String> _splitPoints(Object? raw) =>
    _stripHtml(raw)
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.replaceFirst(RegExp(r'^[\s•·▪●◦\-\*]+'), '').replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);

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
  static const SkillCategory openAccess = SkillCategory(id: -1, name: 'All Skills');

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
    this.topTip = '',
    this.instructions = const <String>[],
    this.categoryId = 0,
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
    description: _oneLine(_stripHtml(json['description'])),
    topTip: _firstText(json, const <String>['top_tip', 'toptip', 'topTip', 'tip']),
    instructions: _bullets(json, const <String>[
      'instructions',
      'instruction',
      'key_points',
      'bullet_points',
      'bullets',
      'steps',
      'how_to',
      'details',
    ]),
    categoryId: _int(json['skill_type_id']),
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

  /// "Top Tip" chip of the detail screen ('' = none).
  final String topTip;

  /// Bullet points shown in the box under the tip (empty = no box).
  final List<String> instructions;

  /// Skill area this drill belongs to (`skill_type_id`; 0 = not sent).
  final int categoryId;
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
    topTip: d.topTip,
    instructions: d.instructions,
    categoryId: d.categoryId == 0 ? categoryId : d.categoryId,
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
    topTip: topTip,
    instructions: instructions,
    categoryId: categoryId,
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
