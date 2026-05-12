import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists and retrieves the current session using secure storage.
class AuthService {
  AuthService() : _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required String userId,
    required String username,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUsername, value: username),
    ]);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUsername),
    ]);
  }

  Future<String?> getToken() => _storage.read(key: _keyToken);

  /// Returns the stored username, or null if no session exists.
  Future<String?> getUsername() => _storage.read(key: _keyUsername);

  Future<bool> isLoggedIn() async => (await getToken()) != null;
}
