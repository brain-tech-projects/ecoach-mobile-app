import 'dart:convert';

import 'package:ecoach_pro/core/constants/storage_keys.dart';
import 'package:ecoach_pro/core/storage/local_storage.dart';

/// Persists the login token and the signed-in user's JSON.
class TokenStorage {
  TokenStorage(this._storage);

  final LocalStorage _storage;

  String? get token {
    final value = _storage.getString(StorageKeys.authToken);
    return (value == null || value.isEmpty) ? null : value;
  }

  Map<String, dynamic>? get userJson {
    final raw = _storage.getString(StorageKeys.authUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.setString(StorageKeys.authToken, token);
    await _storage.setString(StorageKeys.authUser, jsonEncode(user));
  }

  Future<void> clear() async {
    await _storage.remove(StorageKeys.authToken);
    await _storage.remove(StorageKeys.authUser);
  }
}
