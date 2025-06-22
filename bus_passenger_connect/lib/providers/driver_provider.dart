import 'package:flutter/foundation.dart';
import '../models/driver.dart';
import '../services/driver_auth_service.dart';

class DriverProvider extends ChangeNotifier {
  final DriverAuthService _driverAuthService = DriverAuthService();

  Driver? _currentDriver;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  Driver? get currentDriver => _currentDriver;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // Initialize the provider
  Future<void> initialize() async {
    if (kDebugMode) {
      print('DEBUG: Initializing DriverProvider...');
    }

    _setLoading(true);
    _clearError();

    try {
      // Try to auto-login with existing session
      final driver = await _driverAuthService.tryAutoLogin();
      if (driver != null) {
        _setDriver(driver);
        _setAuthenticated(true);
        if (kDebugMode) {
          print('DEBUG: Driver auto-login successful: ${driver.name}');
        }
      } else {
        _setAuthenticated(false);
        if (kDebugMode) {
          print('DEBUG: No existing driver session found');
        }
      }
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
      _setAuthenticated(false);
      if (kDebugMode) {
        print('DEBUG: Driver initialization error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Login with password
  Future<bool> loginWithPassword({
    required String idNumber,
    required String password,
  }) async {
    if (kDebugMode) {
      print('DEBUG: Driver login attempt for ID: $idNumber');
    }

    _setLoading(true);
    _clearError();

    try {
      final driver = await _driverAuthService.loginWithPassword(
        idNumber: idNumber,
        password: password,
      );

      _setDriver(driver);
      _setAuthenticated(true);

      if (kDebugMode) {
        print('DEBUG: Driver login successful: ${driver.name}');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      _setAuthenticated(false);
      if (kDebugMode) {
        print('DEBUG: Driver login error: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login with QR code
  Future<bool> loginWithQRCode(Map<String, dynamic> qrData) async {
    if (kDebugMode) {
      print('DEBUG: Driver QR login attempt');
    }

    _setLoading(true);
    _clearError();

    try {
      final driver = await _driverAuthService.loginWithQRCode(qrData);

      _setDriver(driver);
      _setAuthenticated(true);

      if (kDebugMode) {
        print('DEBUG: Driver QR login successful: ${driver.name}');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      _setAuthenticated(false);
      if (kDebugMode) {
        print('DEBUG: Driver QR login error: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Parse QR code
  Map<String, dynamic>? parseQRCode(String qrCodeString) {
    return _driverAuthService.parseQRCode(qrCodeString);
  }

  // Refresh driver profile
  Future<void> refreshProfile() async {
    if (!_isAuthenticated || _currentDriver == null) return;

    if (kDebugMode) {
      print('DEBUG: Refreshing driver profile...');
    }

    try {
      final updatedDriver = await _driverAuthService.getDriverProfile();
      if (updatedDriver != null) {
        _setDriver(updatedDriver);
        if (kDebugMode) {
          print('DEBUG: Driver profile refreshed successfully');
        }
      }
    } catch (e) {
      _setError('Failed to refresh profile: ${e.toString()}');
      if (kDebugMode) {
        print('DEBUG: Profile refresh error: $e');
      }
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_isAuthenticated) return false;

    if (kDebugMode) {
      print('DEBUG: Attempting to change driver password...');
    }

    _setLoading(true);
    _clearError();

    try {
      await _driverAuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (kDebugMode) {
        print('DEBUG: Driver password changed successfully');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      if (kDebugMode) {
        print('DEBUG: Password change error: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Regenerate QR code
  Future<bool> regenerateQRCode() async {
    if (!_isAuthenticated || _currentDriver == null) return false;

    if (kDebugMode) {
      print('DEBUG: Regenerating driver QR code...');
    }

    _setLoading(true);
    _clearError();

    try {
      final newQRCode = await _driverAuthService.regenerateQRCode();

      // Update current driver with new QR code
      _setDriver(_currentDriver!.copyWith(qrCode: newQRCode));

      if (kDebugMode) {
        print('DEBUG: QR code regenerated successfully');
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      if (kDebugMode) {
        print('DEBUG: QR code regeneration error: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    if (kDebugMode) {
      print('DEBUG: Driver logout...');
    }

    _setLoading(true);
    _clearError();

    try {
      await _driverAuthService.logout();

      _setDriver(null);
      _setAuthenticated(false);

      if (kDebugMode) {
        print('DEBUG: Driver logout successful');
      }
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
      if (kDebugMode) {
        print('DEBUG: Driver logout error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setDriver(Driver? driver) {
    _currentDriver = driver;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update driver data (for external updates)
  void updateDriver(Driver driver) {
    _setDriver(driver);
  }
}
