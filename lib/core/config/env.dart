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

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Full URL for an API media path (absolute URLs are returned unchanged).
  static String? mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return mediaBaseUrl + path.replaceFirst(RegExp(r'^/+'), '');
  }
}
