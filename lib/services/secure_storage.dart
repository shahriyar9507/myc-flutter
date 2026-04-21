import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage so the rest of the app
/// doesn't depend on the plugin directly. Stores the auth bearer token
/// and cached user JSON in the platform keystore/keychain.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUser = 'user_data';
  static const _kPin = 'app_lock_pin';
  static const _kFirebaseToken = 'firebase_token';

  static Future<void> writeToken(String token) => _storage.write(key: _kToken, value: token);
  static Future<String?> readToken() => _storage.read(key: _kToken);
  static Future<void> writeUserId(int id) => _storage.write(key: _kUserId, value: id.toString());
  static Future<int?> readUserId() async {
    final v = await _storage.read(key: _kUserId);
    return v == null ? null : int.tryParse(v);
  }
  static Future<void> writeUser(String json) => _storage.write(key: _kUser, value: json);
  static Future<String?> readUser() => _storage.read(key: _kUser);
  static Future<void> writePin(String pin) => _storage.write(key: _kPin, value: pin);
  static Future<String?> readPin() => _storage.read(key: _kPin);
  static Future<void> deletePin() => _storage.delete(key: _kPin);
  static Future<void> writeFirebaseToken(String t) => _storage.write(key: _kFirebaseToken, value: t);
  static Future<String?> readFirebaseToken() => _storage.read(key: _kFirebaseToken);

  static Future<void> clearAuth() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUser);
    await _storage.delete(key: _kFirebaseToken);
  }
}
