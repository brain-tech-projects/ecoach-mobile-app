/// Build-time switches.
abstract final class AppConfig {
  /// Onboarding is shown ONLY on the very first launch (until the user
  /// finishes it). For demo / QA you can force it on every launch without
  /// touching code:
  ///
  ///   flutter run --dart-define=ALWAYS_SHOW_ONBOARDING=true
  ///
  /// Release builds leave this `false`.
  static const bool alwaysShowOnboarding = bool.fromEnvironment(
    'ALWAYS_SHOW_ONBOARDING',
    defaultValue: false,
  );
}
