import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _authTokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<String?> getAuthToken(String cachedUserId) async {
    return await _storage.read(key: _authTokenKey);
  }

  Future<void> saveUserData({
    required String userId,
    required String email,
    String? name,
    String? token,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    if (name != null) {
      await _storage.write(key: _userNameKey, value: name);
    }
    if (token != null) {
      await _storage.write(key: _authTokenKey, value: token);
    }
  }

  Future<void> saveAuthToken(String token, String userId) async {
    await _storage.write(key: _authTokenKey, value: token);
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    final token = await getAuthToken(userId!);
    return userId != null && token != null;
  }
}
