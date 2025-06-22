import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';
import 'secure_storage_service.dart';
import 'api_service_real.dart';

class DriverAuthException implements Exception {
  final String message;
  final String? code;

  DriverAuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class DriverAuthService {
  // Key for storing current driver in SharedPreferences
  static const String _driverKey = 'current_driver';
  static const String _driverTokenKey = 'driver_auth_token';

  // Secure storage for tokens
  final _secureStorage = SecureStorageService();

  // API Service for backend integration
  final ApiService _apiService = ApiService();

  // Login driver with ID number and password
  Future<Driver> loginWithPassword({
    required String idNumber,
    required String password,
  }) async {
    if (kDebugMode) {
      print('DEBUG: Attempting driver login for ID: $idNumber');
    }

    try {
      final response = await _apiService.post('/api/drivers/auth/login', {
        'idNumber': idNumber,
        'password': password,
      }, requiresAuth: false);

      if (kDebugMode) {
        print('DEBUG: Driver login response: $response');
      }

      // Extract driver data and token from response
      final driverData = response['driver'];
      final token = response['token'];

      final driver = Driver.fromJson(driverData);

      // Save driver session
      await _saveDriverSession(driver, token);

      if (kDebugMode) {
        print('DEBUG: Driver logged in successfully: ${driver.name}');
      }

      return driver;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Driver login error: $e');
      }

      // Handle specific API errors
      if (e.toString().contains('Invalid credentials')) {
        throw DriverAuthException(
          'Invalid ID number or password',
          code: 'invalid-credentials',
        );
      }

      throw DriverAuthException('Login failed: ${e.toString()}');
    }
  }

  // Login driver with QR code data
  Future<Driver> loginWithQRCode(Map<String, dynamic> qrData) async {
    if (kDebugMode) {
      print('DEBUG: Attempting driver QR login: $qrData');
    }

    try {
      final response = await _apiService.post('/api/drivers/auth/login', {
        'qrCodeData': qrData,
      }, requiresAuth: false);

      if (kDebugMode) {
        print('DEBUG: Driver QR login response: $response');
      }

      // Extract driver data and token from response
      final driverData = response['driver'];
      final token = response['token'];

      final driver = Driver.fromJson(driverData);

      // Save driver session
      await _saveDriverSession(driver, token);

      if (kDebugMode) {
        print('DEBUG: Driver logged in with QR successfully: ${driver.name}');
      }

      return driver;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Driver QR login error: $e');
      }

      // Handle specific API errors
      if (e.toString().contains('Invalid QR code')) {
        throw DriverAuthException(
          'Invalid or expired QR code',
          code: 'invalid-qr-code',
        );
      }

      throw DriverAuthException('QR login failed: ${e.toString()}');
    }
  }

  // Parse QR code data
  Map<String, dynamic>? parseQRCode(String qrCodeString) {
    try {
      // Decode JSON from QR code
      final qrData = json.decode(qrCodeString);

      // Validate QR code structure
      if (qrData['type'] == 'DRIVER_AUTH' && qrData['driverId'] != null) {
        return qrData;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to parse QR code: $e');
      }
      return null;
    }
  }

  // Get current driver profile
  Future<Driver?> getDriverProfile() async {
    try {
      final token = await _getDriverToken();
      if (token == null) return null;

      _apiService.setToken(token);

      final response = await _apiService.get('/api/drivers/profile');
      final driverData = response['driver'];

      return Driver.fromJson(driverData);
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to get driver profile: $e');
      }
      return null;
    }
  }

  // Change driver password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getDriverToken();
      if (token == null) {
        throw DriverAuthException('Not authenticated');
      }

      _apiService.setToken(token);

      await _apiService.post('/api/drivers/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (kDebugMode) {
        print('DEBUG: Driver password changed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Password change error: $e');
      }

      if (e.toString().contains('Invalid current password')) {
        throw DriverAuthException(
          'Current password is incorrect',
          code: 'invalid-current-password',
        );
      }

      throw DriverAuthException('Failed to change password: ${e.toString()}');
    }
  }

  // Regenerate QR code
  Future<String> regenerateQRCode() async {
    try {
      final token = await _getDriverToken();
      if (token == null) {
        throw DriverAuthException('Not authenticated');
      }

      final driver = await getCurrentDriver();
      if (driver == null) {
        throw DriverAuthException('Driver not found');
      }

      _apiService.setToken(token);

      final response = await _apiService.post(
        '/api/drivers/${driver.id}/regenerate-qr',
        {},
      );

      final newQRCode = response['qrCode'];

      // Update stored driver with new QR code
      final updatedDriver = driver.copyWith(qrCode: newQRCode);
      await _saveDriverToPrefs(updatedDriver);

      if (kDebugMode) {
        print('DEBUG: QR code regenerated successfully');
      }

      return newQRCode;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: QR code regeneration error: $e');
      }

      throw DriverAuthException(
        'Failed to regenerate QR code: ${e.toString()}',
      );
    }
  }

  // Check if driver is logged in
  Future<bool> isDriverLoggedIn() async {
    final driver = await getCurrentDriver();
    final token = await _getDriverToken();

    if (driver == null || token == null) return false;

    // Check if token is expired
    if (driver.tokenExpiry != null &&
        driver.tokenExpiry!.isBefore(DateTime.now())) {
      await logout();
      return false;
    }

    return true;
  }

  // Get current logged in driver
  Future<Driver?> getCurrentDriver() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverJson = prefs.getString(_driverKey);

      if (driverJson != null) {
        final driverData = json.decode(driverJson);
        return Driver.fromJson(driverData);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Failed to get current driver: $e');
      }
      return null;
    }
  }

  // Logout driver
  Future<void> logout() async {
    try {
      // Clear stored driver data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_driverKey);

      // Clear secure storage
      await _secureStorage.deleteKey(_driverTokenKey);

      // Clear API token
      _apiService.clearToken();

      if (kDebugMode) {
        print('DEBUG: Driver logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Logout error: $e');
      }
    }
  }

  // Private helper methods

  // Save driver session
  Future<void> _saveDriverSession(Driver driver, String token) async {
    // Save driver to SharedPreferences
    await _saveDriverToPrefs(driver);

    // Save token to secure storage
    await _secureStorage.storeKey(_driverTokenKey, token);

    // Set token in API service
    _apiService.setToken(token);
  }

  // Save driver to SharedPreferences
  Future<void> _saveDriverToPrefs(Driver driver) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverKey, json.encode(driver.toJson()));
  }

  // Get driver token from secure storage
  Future<String?> _getDriverToken() async {
    return await _secureStorage.getKey(_driverTokenKey);
  }

  // Auto-login if driver session exists
  Future<Driver?> tryAutoLogin() async {
    try {
      final isLoggedIn = await isDriverLoggedIn();
      if (!isLoggedIn) return null;

      final driver = await getCurrentDriver();
      final token = await _getDriverToken();

      if (driver != null && token != null) {
        _apiService.setToken(token);
        return driver;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Auto-login failed: $e');
      }
      await logout(); // Clear invalid session
      return null;
    }
  }
}
