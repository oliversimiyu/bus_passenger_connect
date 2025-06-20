import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus.dart';

class BusProvider extends ChangeNotifier {
  Bus? _currentBus;
  bool _isOnBus = false;
  String? _selectedStop;
  bool _alertTriggered = false;

  Bus? get currentBus => _currentBus;
  bool get isOnBus => _isOnBus;
  String? get selectedStop => _selectedStop;
  bool get alertTriggered => _alertTriggered;

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
      // In a real app, this would send a notification to the driver
      notifyListeners();
    }
  }

  // Cancel alert
  void cancelAlert() {
    _alertTriggered = false;
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
