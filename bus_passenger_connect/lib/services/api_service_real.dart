import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';
import 'package:bus_passenger_connect/models/location_update.dart';
import 'package:bus_passenger_connect/config/app_config.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;
  String? _token;

  // Set auth token
  void setToken(String token) {
    _token = token;
  }

  // Clear auth token
  void clearToken() {
    _token = null;
  }

  // Get auth headers
  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Handle HTTP responses and errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        print('API Error: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to complete request: ${response.reasonPhrase}');
    }
  }

  // ======== User Authentication APIs ========

  // Register new user
  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
      headers: _getHeaders(requiresAuth: false),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = _handleResponse(response);
    if (data['token'] != null) {
      _token = data['token'];
    }
    return data;
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: _getHeaders(requiresAuth: false),
      body: json.encode({'email': email, 'password': password}),
    );

    final data = _handleResponse(response);
    if (data['token'] != null) {
      _token = data['token'];
    }
    return data;
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: _getHeaders(),
      body: json.encode(profileData),
    );

    return _handleResponse(response);
  }

  // Save a route to user's favorites
  Future<void> saveRoute(String routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/routes/save'),
      headers: _getHeaders(),
      body: json.encode({'routeId': routeId}),
    );

    _handleResponse(response);
  }

  // Get user's saved routes
  Future<List<BusRoute>> getSavedRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/routes/saved'),
      headers: _getHeaders(),
    );

    final data = _handleResponse(response) as List;
    return data.map((routeData) => BusRoute.fromJson(routeData)).toList();
  }

  // ======== Bus Routes APIs ========

  // Get all routes
  Future<List<BusRoute>> getAllRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/routes'),
      headers: _getHeaders(requiresAuth: false),
    );

    final data = _handleResponse(response) as List;
    return data.map((routeData) => BusRoute.fromJson(routeData)).toList();
  }

  // Get nearby routes
  Future<List<BusRoute>> getNearbyRoutes(
    double latitude,
    double longitude, {
    double radius = 5.0,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/routes/nearby?latitude=$latitude&longitude=$longitude&radius=$radius',
      ),
      headers: _getHeaders(requiresAuth: false),
    );

    final data = _handleResponse(response) as List;
    return data.map((routeData) => BusRoute.fromJson(routeData)).toList();
  }

  // Get active routes
  Future<List<dynamic>> getActiveRoutes({int hours = 24}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/location/active?hours=$hours'),
      headers: _getHeaders(requiresAuth: false),
    );

    return _handleResponse(response) as List;
  }

  // Get route by ID
  Future<BusRoute> getRouteById(String routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/routes/$routeId'),
      headers: _getHeaders(requiresAuth: false),
    );

    final data = _handleResponse(response);
    return BusRoute.fromJson(data);
  }

  // Search routes
  Future<List<BusRoute>> searchRoutes(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/routes/search?query=$query'),
      headers: _getHeaders(requiresAuth: false),
    );

    final data = _handleResponse(response) as List;
    return data.map((routeData) => BusRoute.fromJson(routeData)).toList();
  }

  // ======== Location APIs ========

  // Get location updates for a route
  Future<List<LocationUpdate>> getLocationUpdatesForRoute(
    String routeId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/location/route/$routeId'),
      headers: _getHeaders(requiresAuth: false),
    );

    final data = _handleResponse(response) as List;
    return data
        .map((updateData) => LocationUpdate.fromJson(updateData))
        .toList();
  }

  // Create location update (for drivers)
  Future<void> createLocationUpdate(
    String busId,
    String routeId,
    double latitude,
    double longitude,
    double speed,
    double heading,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/location'),
      headers: _getHeaders(),
      body: json.encode({
        'busId': busId,
        'routeId': routeId,
        'position': {'latitude': latitude, 'longitude': longitude},
        'speed': speed,
        'heading': heading,
      }),
    );

    _handleResponse(response);
  }

  // ======== Buses APIs ========

  // Get all buses
  Future<List<dynamic>> getAllBuses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/buses'),
      headers: _getHeaders(requiresAuth: false),
    );

    return _handleResponse(response) as List;
  }

  // Get bus by ID
  Future<Map<String, dynamic>> getBusById(String busId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/buses/$busId'),
      headers: _getHeaders(requiresAuth: false),
    );

    return _handleResponse(response);
  }

  // Update bus status (for drivers)
  Future<Map<String, dynamic>> updateBusStatus(
    String busId,
    String status, {
    String? routeId,
  }) async {
    final Map<String, dynamic> requestData = {'status': status};

    if (routeId != null) {
      requestData['routeId'] = routeId;
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/buses/$busId/status'),
      headers: _getHeaders(),
      body: json.encode(requestData),
    );

    return _handleResponse(response);
  }
}
