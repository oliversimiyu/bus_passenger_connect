import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus.dart';

class BusProvider extends ChangeNotifier {
  Bus? _currentBus;
  bool _isOnBus = false;
  String? _selectedStop;
  bool _alertTriggered = false;
  // Add missing properties
  bool _isAlertTriggered = false;
  double _tripProgress = 0.0;
  String? _currentBusName;
  String? _currentRouteName;
  int _estimatedArrivalTime = 0;
  String? _startStopName;
  String? _endStopName;
  List<String> _remainingStops = [];

  Bus? get currentBus => _currentBus;
  bool get isOnBus => _isOnBus;
  String? get selectedStop => _selectedStop;
  bool get alertTriggered => _alertTriggered;
  // Add missing getters
  bool get isAlertTriggered => _isAlertTriggered;
  double get tripProgress => _tripProgress;
  String? get currentBusName => _currentBusName;
  String? get currentRouteName => _currentRouteName;
  int get estimatedArrivalTime => _estimatedArrivalTime;
  String? get startStopName => _startStopName;
  String? get endStopName => _endStopName;
  List<String> get remainingStops => _remainingStops;

  // Board a bus with the scanned QR code data
  Future<void> boardBus(String busData) async {
    try {
      final busJson = jsonDecode(busData);
      _currentBus = Bus.fromJson(busJson);
      _isOnBus = true;
      _alertTriggered = false;
      _selectedStop = null;

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_bus', busData);
      await prefs.setBool('is_on_bus', true);

      notifyListeners();
    } catch (e) {
      // Handle invalid QR code data
      throw Exception('Invalid bus QR code: $e');
    }
  }

  // Select a stop to alert for
  void selectStop(String stop) {
    _selectedStop = stop;
    notifyListeners();
  }

  // Trigger alert to the driver
  void triggerAlert() {
    if (_isOnBus && _selectedStop != null) {
      _alertTriggered = true;
      _isAlertTriggered = true;
      // In a real app, this would send a notification to the driver
      notifyListeners();
    }
  }

  // Cancel alert
  void cancelAlert() {
    _alertTriggered = false;
    _isAlertTriggered = false;
    notifyListeners();
  }

  // Update trip progress and route information
  void updateTripInfo({
    double? progress,
    String? busName,
    String? routeName,
    int? arrivalTime,
    String? startStop,
    String? endStop,
    List<String>? stops,
  }) {
    if (progress != null) _tripProgress = progress;
    if (busName != null) _currentBusName = busName;
    if (routeName != null) _currentRouteName = routeName;
    if (arrivalTime != null) _estimatedArrivalTime = arrivalTime;
    if (startStop != null) _startStopName = startStop;
    if (endStop != null) _endStopName = endStop;
    if (stops != null) _remainingStops = stops;
    notifyListeners();
  }

  // Exit the bus
  Future<void> exitBus() async {
    _currentBus = null;
    _isOnBus = false;
    _selectedStop = null;
    _alertTriggered = false;

    // Clear from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_bus');
    await prefs.remove('is_on_bus');

    notifyListeners();
  }

  // Load saved bus state when app starts
  Future<void> loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final busData = prefs.getString('current_bus');
    final isOnBus = prefs.getBool('is_on_bus') ?? false;

    if (busData != null && isOnBus) {
      try {
        final busJson = jsonDecode(busData);
        _currentBus = Bus.fromJson(busJson);
        _isOnBus = true;
      } catch (e) {
        // Handle corrupt data
        await exitBus();
      }
    }

    notifyListeners();
  }
}
