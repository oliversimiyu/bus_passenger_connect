import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _biometricsEnabledKey = 'biometrics_enabled';

  // Store auth token
  Future<void> storeAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Store refresh token
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Store user ID
  Future<void> storeUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Store biometrics preference
  Future<void> storeBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricsEnabledKey, value: enabled.toString());
  }

  // Get biometrics preference
  Future<bool> getBiometricsEnabled() async {
    final value = await _storage.read(key: _biometricsEnabledKey);
    return value == 'true';
  }

  // Clear all secure storage data (for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
