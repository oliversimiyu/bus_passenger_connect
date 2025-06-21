import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  // Create storage with platform-specific options
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _biometricsEnabledKey = 'biometrics_enabled';

  // Store auth token
  Future<void> storeAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing auth token: $e');
      }
      rethrow;
    }
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading auth token: $e');
      }
      return null;
    }
  }

  // Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing refresh token: $e');
      }
      rethrow;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading refresh token: $e');
      }
      return null;
    }
  }

  // Store user ID
  Future<void> storeUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error storing user ID: $e');
      }
      rethrow;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading user ID: $e');
      }
      return null;
    }
  }

  // Store biometrics preference
  Future<void> storeBiometricsEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricsEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error storing biometrics enabled: $e');
      }
      rethrow;
    }
  }

  // Get biometrics preference
  Future<bool> getBiometricsEnabled() async {
    try {
      final value = await _storage.read(key: _biometricsEnabledKey);
      return value == 'true';
    } catch (e) {
      if (kDebugMode) {
        print('Error reading biometrics enabled: $e');
      }
      return false;
    }
  }

  // Clear all secure storage data (for logout)
  Future<void> clearAll() async {
    if (kDebugMode) {
      print('Attempting to clear secure storage...');
    }

    try {
      // First try bulk delete
      await _storage.deleteAll();

      if (kDebugMode) {
        print('Secure storage cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing secure storage: $e');
      }

      // Try to delete individual items if bulk delete fails
      try {
        await _storage.delete(key: _authTokenKey);
        await _storage.delete(key: _refreshTokenKey);
        await _storage.delete(key: _userIdKey);
        await _storage.delete(key: _biometricsEnabledKey);

        if (kDebugMode) {
          print('Individual keys cleared successfully');
        }
      } catch (innerError) {
        if (kDebugMode) {
          print('Error clearing individual keys: $innerError');
        }

        // One final attempt with minimal operations
        try {
          // Just clear the auth token as a last resort
          await _storage.delete(key: _authTokenKey);
          if (kDebugMode) {
            print('Auth token cleared as fallback');
          }
        } catch (_) {
          // At this point, we've tried everything
        }
      }
    }
  }
}
