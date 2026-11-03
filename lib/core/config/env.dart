/// Environment values. Override at build time without touching code:
///
///   flutter run --dart-define=API_BASE_URL=https://host/app/api \
///               --dart-define=MEDIA_BASE_URL=https://host/app/storage/
abstract final class Env {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://laravel9.etrueconcept.com/ecoachpro/api',
  );

  /// Images in API responses come as relative paths
  /// (`training-types/abc.webp`); this is the folder they live in.
  static const String mediaBaseUrl = String.fromEnvironment(
    'MEDIA_BASE_URL',
    defaultValue: 'https://laravel9.etrueconcept.com/ecoachpro/storage/',
  );

  /// Skill images / videos (relative paths such as `skill-videos/abc.webp`)
  /// are stored on S3.
  static const String skillMediaBaseUrl = String.fromEnvironment(
    'SKILL_MEDIA_BASE_URL',
    defaultValue: 'https://ecoachpro-training-videos.s3.eu-north-1.amazonaws.com/',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Full URL for an API media path (absolute URLs are returned unchanged).
  static String? mediaUrl(String? path) => _resolve(mediaBaseUrl, path);

  /// Same for skill images and videos (S3).
  static String? skillMediaUrl(String? path) =>
      _resolve(skillMediaBaseUrl, path);

  static String? _resolve(String base, String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return base + path.replaceFirst(RegExp(r'^/+'), '');
  }
}
