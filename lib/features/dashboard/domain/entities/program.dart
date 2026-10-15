import 'package:flutter/foundation.dart';

/// A row in "Popular Programs".
@immutable
class Program {
  const Program({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
  });

  final String id;
  final String title;
  final String description;

  /// An `assets/...` path (dummy data) or an `https://...` URL (API).
  final String thumbnail;
}
