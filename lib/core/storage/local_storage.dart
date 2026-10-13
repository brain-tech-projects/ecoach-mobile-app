import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecoach_pro/core/constants/storage_keys.dart';

/// Thin wrapper over [SharedPreferences] so the rest of the app never
/// depends on the plugin directly (easy to mock / swap).
class LocalStorage {
  LocalStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage._(prefs);
  }

  // ---- Onboarding ---------------------------------------------------------
  bool get isOnboardingCompleted =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<bool> setOnboardingCompleted(bool value) =>
      _prefs.setBool(StorageKeys.onboardingCompleted, value);

  // ---- Generic helpers ----------------------------------------------------
  bool? getBool(String key) => _prefs.getBool(key);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}