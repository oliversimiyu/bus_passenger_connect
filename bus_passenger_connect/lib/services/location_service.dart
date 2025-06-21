import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus_passenger_connect/models/location_update.dart';

class LocationService {
  final StreamController<LocationUpdate> _locationController =
      StreamController<LocationUpdate>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;

  Stream<LocationUpdate> get locationStream => _locationController.stream;
  final List<LatLng> _routeHistory = [];
  bool _isSimulated = false;
  Timer? _simulationTimer;

  bool get isSimulated => _isSimulated;
  List<LatLng> get routeHistory => _routeHistory;

  // Initialize the service and check permissions
  Future<bool> initialize() async {
    // For platforms that don't support location services
    if (!_isPlatformSupported()) {
      if (kDebugMode) {
        print(
          'Platform not supported for location services. Using simulated data.',
        );
      }
      _isSimulated = true;
      return true;
    }

    try {
      if (kDebugMode) {
        print('Checking location services...');
      }
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        _isSimulated = true;
        return true;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, switch to simulated mode
          _isSimulated = true;
          return true;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, switch to simulated mode
        _isSimulated = true;
        return true;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing location service: $e');
      }
      _isSimulated = true;
      return true;
    }
  }

  // Check if the current platform supports location services
  bool _isPlatformSupported() {
    // Always use simulated location for web
    if (kIsWeb) {
      return false;
    }

    // For native platforms, we'd check the platform
    // Use a try-catch block to handle platform exceptions
    try {
      // Import dart:io conditionally
      if (!kIsWeb) {
        // This is a runtime check that doesn't require importing dart:io
        return true;
      }
      return false;
    } catch (e) {
      // If there's any issue, default to simulated mode
      if (kDebugMode) {
        print('Error checking platform: $e');
      }
      return false;
    }
  }

  // Start tracking user location
  Future<void> startTracking() async {
    await initialize();
    _routeHistory.clear();

    if (_isSimulated) {
      _startSimulatedTracking();
    } else {
      _startRealTracking();
    }
  }

  // Start real location tracking
  void _startRealTracking() {
    try {
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update if moved 10 meters
            ),
          ).listen(
            (Position position) {
              final locationUpdate = LocationUpdate(
                position: LatLng(position.latitude, position.longitude),
                speed: position.speed, // m/s
                heading: position.heading, // degrees
                timestamp: DateTime.now(),
              );

              _locationController.add(locationUpdate);
              _routeHistory.add(LatLng(position.latitude, position.longitude));
            },
            onError: (e) {
              if (kDebugMode) {
                print('Error in location stream: $e');
              }
              // Switch to simulated mode if real tracking fails
              _startSimulatedTracking();
            },
          );
    } catch (e) {
      if (kDebugMode) {
        print('Error starting location tracking: $e');
      }
      _startSimulatedTracking();
    }
  }

  // Simulated location tracking for platforms without location support
  void _startSimulatedTracking() {
    _isSimulated = true;

    // Create a list of simulated route points around Nairobi, Kenya
    final List<LatLng> simulatedRoute = [
      const LatLng(-1.2921, 36.8219), // Nairobi CBD
      const LatLng(-1.2876, 36.8208), // Near Central Park
      const LatLng(-1.2832, 36.8184), // University of Nairobi area
      const LatLng(-1.2789, 36.8156), // Moving towards Westlands
      const LatLng(-1.2747, 36.8085), // Parklands
      const LatLng(-1.2641, 36.8028), // Westlands
    ];

    int currentIndex = 0;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentIndex < simulatedRoute.length) {
        final location = simulatedRoute[currentIndex];
        final locationUpdate = LocationUpdate(
          position: location,
          speed: 15.0, // simulated speed in m/s (about 54 km/h)
          heading: 45.0, // simulated heading (northeast)
          timestamp: DateTime.now(),
        );

        _locationController.add(locationUpdate);
        _routeHistory.add(location);
        currentIndex++;
        
        if (kDebugMode) {
          print('Simulated location update: ${location.latitude}, ${location.longitude}');
        }
      } else {
        // Start over when we reach the end
        currentIndex = 0;
        _routeHistory.clear(); // Clear history to start fresh
      }
    });
    
    if (kDebugMode) {
      print('Started simulated tracking in Nairobi, Kenya');
    }
  }

  // Stop tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  // Dispose resources
  void dispose() {
    stopTracking();
    _locationController.close();
  }

  // Get the current position once
  Future<LocationUpdate?> getCurrentLocation() async {
    await initialize();

    if (_isSimulated) {
      // Return Kenya default location for simulation
      return LocationUpdate(
        position: const LatLng(-1.2921, 36.8219), // Nairobi, Kenya
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      );
    } else {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        final locationUpdate = LocationUpdate(
          position: LatLng(position.latitude, position.longitude),
          speed: position.speed,
          heading: position.heading,
          timestamp: DateTime.now(),
        );

        // Add to location controller
        _locationController.add(locationUpdate);
        
        if (kDebugMode) {
          print('Current location: ${position.latitude}, ${position.longitude}');
        }

        return locationUpdate;
      } catch (e) {
        if (kDebugMode) {
          print('Error getting current location: $e');
        }
        // Fall back to Kenya default location on error
        _isSimulated = true;
        return LocationUpdate(
          position: const LatLng(-1.2921, 36.8219), // Nairobi, Kenya
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        );
      }
    }
  }
}
