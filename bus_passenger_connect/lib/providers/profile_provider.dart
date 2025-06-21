import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_passenger_connect/models/user_profile.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';
import 'package:bus_passenger_connect/models/user.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _storageKey = 'user_profile_data';
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // Constructor
  ProfileProvider() {
    _loadUserProfile();
  }

  // Load user profile from storage
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_storageKey);

      if (profileString != null) {
        final profileData = json.decode(profileString);
        _userProfile = UserProfile.fromJson(profileData);

        // Validate the loaded profile isn't using default values
        if (_userProfile?.id == 'guest' ||
            _userProfile?.name == 'Guest User' ||
            _userProfile?.email == 'guest@example.com') {
          // Don't load default profiles from storage
          _userProfile = null;
        }
      }

      // If profile is still null, create a temporary guest profile
      // but don't save it - we'll wait for proper user data
      _userProfile ??= UserProfile(
        id: 'guest',
        name: 'Guest User',
        email: 'guest@example.com',
      );

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }

      // Create default profile on error, but don't save it
      _userProfile = UserProfile(
        id: 'guest',
        name: 'Guest User',
        email: 'guest@example.com',
      );
      notifyListeners();
    }
  }

  // Save user profile to storage
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = json.encode(_userProfile!.toJson());
      await prefs.setString(_storageKey, profileString);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user profile: $e');
      }
    }
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(name: name, email: email);

    await _saveUserProfile();
    notifyListeners();
  }

  // Add a favorite route
  Future<void> addFavoriteRoute(String routeId) async {
    if (_userProfile == null) return;

    if (!_userProfile!.favoriteRouteIds.contains(routeId)) {
      final updatedFavorites = List<String>.from(_userProfile!.favoriteRouteIds)
        ..add(routeId);

      _userProfile = _userProfile!.copyWith(favoriteRouteIds: updatedFavorites);
      await _saveUserProfile();
      notifyListeners();
    }
  }

  // Remove a favorite route
  Future<void> removeFavoriteRoute(String routeId) async {
    if (_userProfile == null) return;

    if (_userProfile!.favoriteRouteIds.contains(routeId)) {
      final updatedFavorites = List<String>.from(_userProfile!.favoriteRouteIds)
        ..remove(routeId);

      _userProfile = _userProfile!.copyWith(favoriteRouteIds: updatedFavorites);
      await _saveUserProfile();
      notifyListeners();
    }
  }

  // Add travel history entry
  Future<void> addTravelHistory(BusRoute route, DateTime date) async {
    if (_userProfile == null) return;

    final historyEntry = {
      'routeId': route.id,
      'routeName': route.name,
      'date': date.toIso8601String(),
      'startLocation':
          '${route.startLocation.latitude},${route.startLocation.longitude}',
      'endLocation':
          '${route.endLocation.latitude},${route.endLocation.longitude}',
    };

    final updatedHistory = List<Map<String, dynamic>>.from(
      _userProfile!.travelHistory,
    )..insert(0, historyEntry); // Add to beginning of list

    _userProfile = _userProfile!.copyWith(travelHistory: updatedHistory);
    await _saveUserProfile();
    notifyListeners();
  }

  // Clear all travel history
  Future<void> clearTravelHistory() async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(travelHistory: []);
    await _saveUserProfile();
    notifyListeners();
  }

  // New method to sync with authenticated user
  Future<void> syncWithAuthUser(User? user) async {
    if (user == null) {
      // If user is null, just use default profile or clear
      return;
    }

    // Update user profile with authenticated user data
    _userProfile =
        _userProfile?.copyWith(
          id: user.id,
          name: user.name,
          email: user.email,
          profileImageUrl: user.photoUrl,
        ) ??
        UserProfile(
          id: user.id,
          name: user.name,
          email: user.email,
          profileImageUrl: user.photoUrl,
          favoriteRouteIds: const [],
          favoriteRoutes: const [],
          travelHistory: const [],
        );

    // Save updated profile
    await _saveUserProfile();
    notifyListeners();
  }
}
