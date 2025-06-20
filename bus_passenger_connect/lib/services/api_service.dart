import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// An abstract API service class that can be extended for real API implementation
abstract class ApiService {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> delete(String endpoint);
}

/// A mock implementation of ApiService for testing and development
class MockApiService implements ApiService {
  // Storage key for mock data
  static const String _storageKey = 'mock_api_data';

  // Initialize with default data if needed
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_storageKey)) {
      // Set up initial mock data
      final initialData = {'users': [], 'buses': [], 'trips': []};
      await prefs.setString(_storageKey, jsonEncode(initialData));
    }
  }

  // Get all stored data
  Future<Map<String, dynamic>> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_storageKey);
    if (dataStr == null) {
      await initialize();
      return _getData();
    }
    return jsonDecode(dataStr) as Map<String, dynamic>;
  }

  // Save all data
  Future<void> _saveData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final data = await _getData();
    final segments = endpoint.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      throw Exception('Invalid endpoint');
    }

    // Handle specific endpoints
    switch (segments[0]) {
      case 'users':
        if (segments.length == 1) {
          return {'users': data['users'] ?? []};
        } else if (segments.length == 2) {
          final userId = segments[1];
          final user = (data['users'] as List?)?.firstWhere(
            (u) => u['id'] == userId,
            orElse: () => null,
          );
          if (user == null) {
            throw Exception('User not found');
          }
          return user as Map<String, dynamic>;
        }
        break;
      case 'buses':
        if (segments.length == 1) {
          return {'buses': data['buses'] ?? []};
        } else if (segments.length == 2) {
          final busId = segments[1];
          final bus = (data['buses'] as List?)?.firstWhere(
            (b) => b['id'] == busId,
            orElse: () => null,
          );
          if (bus == null) {
            throw Exception('Bus not found');
          }
          return bus as Map<String, dynamic>;
        }
        break;
    }

    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = await _getData();
    final segments = endpoint.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      throw Exception('Invalid endpoint');
    }

    // Handle specific endpoints
    switch (segments[0]) {
      case 'users':
        if (segments.length == 1) {
          // Create a new user
          final users = allData['users'] as List? ?? [];

          // Check if email already exists
          final emailExists = users.any((u) => u['email'] == data['email']);
          if (emailExists) {
            throw Exception('Email already in use');
          }

          // Add ID if not provided
          if (!data.containsKey('id')) {
            data['id'] = 'user_${DateTime.now().millisecondsSinceEpoch}';
          }

          users.add(data);
          allData['users'] = users;
          await _saveData(allData);
          return data;
        }
        break;
      case 'auth':
        if (segments.length == 2 && segments[1] == 'login') {
          // Login endpoint
          final users = allData['users'] as List? ?? [];
          final user = users.firstWhere(
            (u) =>
                u['email'] == data['email'] &&
                u['password'] == data['password'],
            orElse: () => null,
          );

          if (user == null) {
            throw Exception('Invalid credentials');
          }

          // Return user without password
          final userData = Map<String, dynamic>.from(user as Map);
          userData.remove('password');
          return userData;
        }
        break;
    }

    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = await _getData();
    final segments = endpoint.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      throw Exception('Invalid endpoint');
    }

    // Handle specific endpoints
    switch (segments[0]) {
      case 'users':
        if (segments.length == 2) {
          final userId = segments[1];
          final users = allData['users'] as List? ?? [];

          final index = users.indexWhere((u) => u['id'] == userId);
          if (index == -1) {
            throw Exception('User not found');
          }

          // Update user data
          users[index] = {...users[index] as Map<dynamic, dynamic>, ...data};
          allData['users'] = users;
          await _saveData(allData);
          return users[index] as Map<String, dynamic>;
        }
        break;
    }

    throw Exception('Endpoint not found: $endpoint');
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allData = await _getData();
    final segments = endpoint.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      throw Exception('Invalid endpoint');
    }

    // Handle specific endpoints
    switch (segments[0]) {
      case 'users':
        if (segments.length == 2) {
          final userId = segments[1];
          final users = allData['users'] as List? ?? [];

          final index = users.indexWhere((u) => u['id'] == userId);
          if (index == -1) {
            throw Exception('User not found');
          }

          final removed = users.removeAt(index);
          allData['users'] = users;
          await _saveData(allData);
          return removed as Map<String, dynamic>;
        }
        break;
    }

    throw Exception('Endpoint not found: $endpoint');
  }
}
