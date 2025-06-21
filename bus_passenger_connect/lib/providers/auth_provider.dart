import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorCode;
  bool _biometricsAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get biometricsAvailable => _biometricsAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get canUseBiometrics =>
      _biometricsAvailable && _availableBiometrics.isNotEmpty;
  bool get isBiometricsEnabled => _currentUser?.useBiometrics ?? false;

  // Initialize the provider by checking for existing session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check biometrics availability
      _biometricsAvailable = await _authService.isBiometricsAvailable();
      if (_biometricsAvailable) {
        _availableBiometrics = await _authService.getAvailableBiometrics();
      }

      // Get current user
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up a new user
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _currentUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in an existing user
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with biometrics
  Future<bool> signInWithBiometrics() async {
    if (!_biometricsAvailable || _availableBiometrics.isEmpty) {
      _setError('Biometric authentication not available on this device');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithBiometrics();
      return _currentUser != null;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password with code
  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      await _authService.resetPassword(email, code, newPassword);
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _currentUser = await _authService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        photoUrl: photoUrl,
      );
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enable/disable biometric authentication
  Future<bool> updateBiometrics(bool useBiometrics) async {
    if (_currentUser == null) {
      _setError('Not authenticated');
      return false;
    }

    if (useBiometrics && !_biometricsAvailable) {
      _setError('Biometric authentication not available on this device');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _currentUser = await _authService.updateBiometrics(
        _currentUser!.id,
        useBiometrics,
      );
      return true;
    } catch (e) {
      if (e is AuthException) {
        _setError(e.message, e.code);
      } else {
        _setError(e.toString());
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Call the auth service sign out method
      await _authService.signOut();

      // Clear all user-related state
      _currentUser = null;
      _biometricsAvailable = false;
      _availableBiometrics = [];

      // Extra cleanup to ensure a clean sign out
      await Future.delayed(const Duration(milliseconds: 100));

      if (kDebugMode) {
        print("Sign out completed in AuthProvider");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign out: $e");
      }
      _setError(e.toString());
      // Even if there's an error, we should clear the user state
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force sign out in case the normal flow fails
  void forceSignOut() {
    _currentUser = null;
    _isLoading = false;
    _biometricsAvailable = false;
    _availableBiometrics = [];
    notifyListeners();

    if (kDebugMode) {
      print("Force sign out completed");
    }
  }

  // Set error message and code
  void _setError(String message, [String? code]) {
    _errorMessage = message;
    _errorCode = code;
  }

  // Clear any error messages
  void _clearError() {
    _errorMessage = null;
    _errorCode = null;
  }

  // Clear errors publicly
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
