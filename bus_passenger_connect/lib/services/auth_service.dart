import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  // Mock user database (In a real app, this would be a server/database)
  static final Map<String, Map<String, dynamic>> _users = {};

  // Key for storing current user in SharedPreferences
  static const String _userKey = 'current_user';

  // Secure storage for tokens
  final _secureStorage = SecureStorageService();

  // Local authentication
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Mock API Service for future integration
  final MockApiService _apiService = MockApiService();

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

    // Check if email already exists
    if (_users.containsKey(email)) {
      throw AuthException('Email already in use', code: 'email-already-in-use');
    }

    // Password validation
    if (password.length < 6) {
      throw AuthException(
        'Password must be at least 6 characters long',
        code: 'weak-password',
      );
    }

    // Create new user (with a simulated ID)
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Generate mock auth token and expiry (24 hours from now)
    final token = _generateToken();
    final tokenExpiry = DateTime.now().add(const Duration(hours: 24));

    final newUser = User(
      id: userId,
      name: name,
      email: email,
      authToken: token,
      tokenExpiry: tokenExpiry,
    );

    // Store user in our mock database
    _users[email] = {
      ...newUser.toJson(),
      'password': password, // In a real app, this would be hashed
    };

    // Save token in secure storage
    await _secureStorage.storeAuthToken(token);
    await _secureStorage.storeUserId(userId);

    // Save user to SharedPreferences for session persistence
    await _saveUserToPrefs(newUser);

    return newUser;
  }

  // Log in an existing user
  Future<User> signIn({required String email, required String password}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user exists
    if (!_users.containsKey(email)) {
      throw AuthException(
        'No account found with this email',
        code: 'user-not-found',
      );
    }

    // Check password
    final userData = _users[email]!;
    if (userData['password'] != password) {
      throw AuthException('Invalid password', code: 'wrong-password');
    }

    // Generate mock auth token and expiry (24 hours from now)
    final token = _generateToken();
    final tokenExpiry = DateTime.now().add(const Duration(hours: 24));

    // Create user object
    final user = User.fromJson({
      'id': userData['id'],
      'name': userData['name'],
      'email': userData['email'],
      'photoUrl': userData['photoUrl'],
      'authToken': token,
      'tokenExpiry': tokenExpiry.toIso8601String(),
      'useBiometrics': userData['useBiometrics'] ?? false,
    });

    // Save token in secure storage
    await _secureStorage.storeAuthToken(token);
    await _secureStorage.storeUserId(user.id);

    // Save user to SharedPreferences for session persistence
    await _saveUserToPrefs(user);

    return user;
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

      // Generate new token
      final token = _generateToken();
      final tokenExpiry = DateTime.now().add(const Duration(hours: 24));

      // Update user with new token
      final updatedUser = currentUser.copyWith(
        authToken: token,
        tokenExpiry: tokenExpiry,
      );

      // Save token in secure storage
      await _secureStorage.storeAuthToken(token);

      // Save updated user to SharedPreferences
      await _saveUserToPrefs(updatedUser);

      return updatedUser;
    } on PlatformException catch (e) {
      throw AuthException('Biometric authentication error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Authentication error: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);

    // Clear secure storage
    await _secureStorage.clearAll();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    // Validate email
    if (!EmailValidator.validate(email)) {
      throw AuthException('Invalid email format');
    }

    // Check if user exists
    if (!_users.containsKey(email)) {
      // For security reasons, don't reveal that the user doesn't exist
      // Just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // In a real app, this would send an email with a reset link
    // For now, just simulate the API call
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, you'd typically return a success message or token
    return;
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

    // Check if user exists
    if (!_users.containsKey(email)) {
      throw AuthException('No account found with this email');
    }

    // In a real app, you would verify the reset code
    // For the mock implementation, we'll just accept any 6-digit code
    final isValidCode = RegExp(r'^\d{6}$').hasMatch(code);
    if (!isValidCode) {
      throw AuthException('Invalid reset code');
    }

    // Update the password
    final userData = _users[email]!;
    userData['password'] = newPassword;
    _users[email] = userData;

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    return;
  }

  // Update user profile
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    // Find user by ID
    final userEntry = _users.entries.firstWhere(
      (entry) => entry.value['id'] == userId,
      orElse: () => throw AuthException('User not found'),
    );

    final userData = userEntry.value;

    // Update user data
    if (name != null) userData['name'] = name;
    if (photoUrl != null) userData['photoUrl'] = photoUrl;

    // Create updated user object
    final updatedUser = User.fromJson(userData);

    // Save to SharedPreferences
    await _saveUserToPrefs(updatedUser);

    return updatedUser;
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

    // Find user by ID
    final userEntry = _users.entries.firstWhere(
      (entry) => entry.value['id'] == userId,
      orElse: () => throw AuthException('User not found'),
    );

    final userData = userEntry.value;

    // Update biometrics setting
    userData['useBiometrics'] = useBiometrics;

    // Save setting to secure storage
    await _secureStorage.storeBiometricsEnabled(useBiometrics);

    // Create updated user object
    final updatedUser = User.fromJson(userData);

    // Save to SharedPreferences
    await _saveUserToPrefs(updatedUser);

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
        // Token expired, attempt to refresh it
        try {
          return await _refreshToken(user);
        } catch (e) {
          // If refresh fails, sign out user
          await signOut();
          return null;
        }
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  // Refresh the authentication token
  Future<User> _refreshToken(User user) async {
    // In a real app, this would call a refresh token endpoint
    // For now, just generate a new token
    final token = _generateToken();
    final tokenExpiry = DateTime.now().add(const Duration(hours: 24));

    final refreshedUser = user.copyWith(
      authToken: token,
      tokenExpiry: tokenExpiry,
    );

    // Save token in secure storage
    await _secureStorage.storeAuthToken(token);

    // Save updated user to SharedPreferences
    await _saveUserToPrefs(refreshedUser);

    return refreshedUser;
  }

  // Save user to SharedPreferences for persistence
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Generate a random token (for mock purposes)
  String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      List.generate(64, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
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
