import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Google Maps API Key Configuration
  // To get a valid API key:
  // 1. Go to https://console.cloud.google.com/
  // 2. Create or select a project
  // 3. Enable Maps SDK for Android/iOS
  // 4. Create credentials (API Key)
  // 5. Restrict the key to your app's package name
  // 6. Replace the key below with your actual key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  // For testing purposes, we'll use a fallback that shows map tiles but with watermarks
  static const String fallbackMapsApiKey = 'AIzaSyBt6csGnCnYsHGXwQE-QFGOuwhfvOWQw-Q';
  
  // Get the API key to use (with fallback)
  static String get effectiveGoogleMapsApiKey {
    if (googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      return googleMapsApiKey;
    }
    return fallbackMapsApiKey;
  }

  // Default map settings for Kenya
  static const double defaultLatitude = -1.2921; // Nairobi, Kenya
  static const double defaultLongitude = 36.8219;
  static const double defaultZoom = 13.0;

  // API configuration - automatically detects the correct URL
  static String get apiBaseUrl {
    if (kIsWeb) {
      // For web, use localhost
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or real device
      // For real Android devices, use your computer's IP
      return 'http://192.168.100.129:5000';
    } else if (Platform.isIOS) {
      // For iOS devices/simulator, use your computer's IP
      return 'http://192.168.100.129:5000';
    } else {
      // Fallback
      return 'http://localhost:5000';
    }
  }
}
