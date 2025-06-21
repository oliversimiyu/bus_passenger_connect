import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import 'secure_storage_service.dart';
import 'api_service_real.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  // Key for storing current user in SharedPreferences
  static const String _userKey = 'current_user';

  // Secure storage for tokens
  final _secureStorage = SecureStorageService();

  // Local authentication
  final LocalAuthentication _localAuth = LocalAuthentication();

  // API Service for backend integration
  final ApiService _apiService = ApiService();

  // Create a new user account
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validate email format
    if (!EmailValidator.validate(email)) {
      throw AuthException('Invalid email format');
    }

    // Password validation
    if (password.length < 6) {
      throw AuthException(
        'Password must be at least 6 characters long',
        code: 'weak-password',
      );
    }

    try {
      // Register user via API
      final response = await _apiService.registerUser(
        name,
        email,
        password,
        '', // phoneNumber - optional for now
      );

      if (kDebugMode) {
        print('DEBUG: Registration response: $response');
      }

      // Extract user data and token from response
      final userData = response['user'];
      final token = response['token'];

      // Calculate token expiry (7 days as per backend)
      final tokenExpiry = DateTime.now().add(const Duration(days: 7));

      final newUser = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        authToken: token,
        tokenExpiry: tokenExpiry,
      );

      // Set token in API service for future requests
      _apiService.setToken(token);

      // Save token in secure storage
      await _secureStorage.storeAuthToken(token);
      await _secureStorage.storeUserId(userData['id']);

      // Save user to SharedPreferences for session persistence
      await _saveUserToPrefs(newUser);

      if (kDebugMode) {
        print('DEBUG: User registered successfully: ${newUser.email}');
      }

      return newUser;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Registration error: $e');
      }

      // Handle specific API errors
      if (e.toString().contains('User already exists')) {
        throw AuthException(
          'Email already in use',
          code: 'email-already-in-use',
        );
      }

      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  // Log in an existing user
  Future<User> signIn({required String email, required String password}) async {
    if (kDebugMode) {
      print('DEBUG: Attempting sign in for email: $email');
    }

    try {
      // Login user via API
      final response = await _apiService.loginUser(email, password);

      if (kDebugMode) {
        print('DEBUG: Login response: $response');
      }

      // Extract user data and token from response
      final userData = response['user'];
      final token = response['token'];

      // Calculate token expiry (7 days as per backend)
      final tokenExpiry = DateTime.now().add(const Duration(days: 7));

      final user = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        authToken: token,
        tokenExpiry: tokenExpiry,
      );

      // Set token in API service for future requests
      _apiService.setToken(token);

      // Save token in secure storage
      await _secureStorage.storeAuthToken(token);
      await _secureStorage.storeUserId(userData['id']);

      // Save user to SharedPreferences for session persistence
      await _saveUserToPrefs(user);

      if (kDebugMode) {
        print('DEBUG: User signed in successfully: ${user.email}');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Sign in error: $e');
      }

      // Handle specific API errors
      if (e.toString().contains('Invalid email or password')) {
        throw AuthException(
          'Invalid email or password',
          code: 'wrong-password',
        );
      }

      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // Sign in with biometrics
  Future<User?> signInWithBiometrics() async {
    try {
      // Check if biometrics is available and enrolled
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        throw AuthException(
          'Biometric authentication not available on this device',
        );
      }

      // Get user ID from secure storage
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        throw AuthException('No stored credentials found');
      }

      // Check if biometrics is enabled for this user
      final isBiometricsEnabled = await _secureStorage.getBiometricsEnabled();
      if (!isBiometricsEnabled) {
        throw AuthException(
          'Biometric authentication not enabled for this account',
        );
      }

      // Authenticate with biometrics
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        throw AuthException('Biometric authentication failed');
      }

      // Get current user from SharedPreferences
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw AuthException('User data not found');
      }

      // Verify the existing token is still valid
      if (!currentUser.isTokenValid) {
        throw AuthException('Session expired, please log in again');
      }

      // Set token in API service for future requests
      if (currentUser.authToken != null) {
        _apiService.setToken(currentUser.authToken!);
      }

      if (kDebugMode) {
        print('DEBUG: Biometric authentication successful');
      }

      return currentUser;
    } on PlatformException catch (e) {
      throw AuthException('Biometric authentication error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Authentication error: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print("Starting sign out process...");
      }

      // First clear secure storage as it's most critical
      await _secureStorage.clearAll();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      // For extra safety, clear all data in shared preferences that might be related to the user
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('user_') ||
            key.contains('token') ||
            key.contains('auth')) {
          await prefs.remove(key);
        }
      }

      // Small delay to ensure everything is flushed
      await Future.delayed(const Duration(milliseconds: 100));

      if (kDebugMode) {
        print("Sign out completed successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign out: $e");
      }
      // Continue with partial sign out even if there's an error
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userKey);

        // One more attempt to clear secure storage
        await _secureStorage.clearAll();
      } catch (finalError) {
        if (kDebugMode) {
          print("Final error in sign out: $finalError");
        }
      }
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    // Validate email
    if (!EmailValidator.validate(email)) {
      throw AuthException('Invalid email format');
    }

    try {
      // In a real backend implementation, you would call an API endpoint here
      // For now, just simulate the API call
      await Future.delayed(const Duration(milliseconds: 1000));

      if (kDebugMode) {
        print('DEBUG: Password reset email sent to: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Error sending password reset email: $e');
      }
      throw AuthException('Failed to send password reset email');
    }
  }

  // Reset password with code
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    // Validate inputs
    if (!EmailValidator.validate(email)) {
      throw AuthException('Invalid email format');
    }

    if (newPassword.length < 6) {
      throw AuthException('Password must be at least 6 characters long');
    }

    try {
      // In a real app, you would verify the reset code with the backend
      // and then call an API endpoint to reset the password
      final isValidCode = RegExp(r'^\d{6}$').hasMatch(code);
      if (!isValidCode) {
        throw AuthException('Invalid reset code');
      }

      // Simulate API call for password reset
      await Future.delayed(const Duration(milliseconds: 1000));

      if (kDebugMode) {
        print('DEBUG: Password reset successfully for email: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Error resetting password: $e');
      }
      if (e is AuthException) rethrow;
      throw AuthException('Failed to reset password');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      // Prepare update data
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (photoUrl != null) updateData['profilePicture'] = photoUrl;

      // Update profile via API
      final response = await _apiService.updateUserProfile(updateData);

      if (kDebugMode) {
        print('DEBUG: Profile update response: $response');
      }

      // Get current token from secure storage
      final token = await _secureStorage.getAuthToken();
      final tokenExpiry = DateTime.now().add(const Duration(days: 7));

      // Create updated user object
      final updatedUser = User(
        id: response['_id'],
        name: response['name'],
        email: response['email'],
        photoUrl: response['profilePicture'],
        authToken: token,
        tokenExpiry: tokenExpiry,
      );

      // Save to SharedPreferences
      await _saveUserToPrefs(updatedUser);

      if (kDebugMode) {
        print('DEBUG: Profile updated successfully');
      }

      return updatedUser;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Profile update error: $e');
      }
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  // Enable/disable biometric authentication
  Future<User> updateBiometrics(String userId, bool useBiometrics) async {
    // Check if biometrics is available on this device
    if (useBiometrics) {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        throw AuthException(
          'Biometric authentication not available on this device',
        );
      }

      // If enabling, verify with biometrics first
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        throw AuthException('Biometric authentication failed');
      }
    }

    // Since biometrics is a local device setting, we store it locally
    // Get current user from SharedPreferences
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw AuthException('No user logged in');
    }

    // Update biometrics setting locally
    final updatedUser = currentUser.copyWith(useBiometrics: useBiometrics);

    // Save setting to secure storage
    await _secureStorage.storeBiometricsEnabled(useBiometrics);

    // Save to SharedPreferences
    await _saveUserToPrefs(updatedUser);

    if (kDebugMode) {
      print('DEBUG: Biometrics setting updated to: $useBiometrics');
    }

    return updatedUser;
  }

  // Check if a user is currently logged in
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) {
      return null;
    }

    try {
      final user = User.fromJson(jsonDecode(userJson));

      // Check if token is expired
      if (!user.isTokenValid) {
        if (kDebugMode) {
          print('DEBUG: Token expired, clearing user session');
        }
        await signOut();
        return null;
      }

      // Set token in API service for future requests
      if (user.authToken != null) {
        _apiService.setToken(user.authToken!);
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG: Error loading current user: $e');
      }
      return null;
    }
  }

  // Save user to SharedPreferences for persistence
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
