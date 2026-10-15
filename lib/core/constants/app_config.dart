/// Build-time switches. Flip these when real behaviour is implemented.
abstract final class AppConfig {
  /// TEMPORARY (demo / QA): always show onboarding after the splash.
  /// Set to `false` to show it only on first launch (the "completed" flag is
  /// already stored by the onboarding controller).
  static const bool alwaysShowOnboarding = true;
}
