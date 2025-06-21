// filepath: /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect/lib/providers/map_provider_real.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';
import 'package:bus_passenger_connect/models/location_update.dart';
import 'package:bus_passenger_connect/services/location_service.dart';
import 'package:bus_passenger_connect/services/directions_service.dart';
import 'package:bus_passenger_connect/services/api_service_real.dart';
import 'package:bus_passenger_connect/utils/debug_logger.dart';

enum MapTrackingMode { free, followUser, followRoute }

class MapProviderReal extends ChangeNotifier {
  // Services
  final LocationService _locationService;
  final DirectionsService _directionsService;
  final ApiService _apiService = ApiService();

  // Debug logging
  static const String _logTag = 'MapProvider';

  // Current state
  LocationUpdate? _currentLocation;
  BusRoute? _currentRoute;
  Set<Polyline> _routePolylines = {};
  Set<Marker> _markers = {};
  MapTrackingMode _trackingMode = MapTrackingMode.free;
  bool _isRouteActive = false;
  bool _isLoading = false;

  // Route data
  List<BusRoute> _availableRoutes = [];

  // Subscription to location updates
  StreamSubscription<LocationUpdate>? _locationSubscription;

  // Controller for the map
  GoogleMapController? _mapController;

  // Getters
  LocationUpdate? get currentLocation => _currentLocation;
  BusRoute? get currentRoute => _currentRoute;
  Set<Polyline> get routePolylines => _routePolylines;
  Set<Marker> get markers => _markers;
  MapTrackingMode get trackingMode => _trackingMode;
  bool get isRouteActive => _isRouteActive;
  bool get isLoading => _isLoading;
  List<BusRoute> get availableRoutes => _availableRoutes;

  // Constructor
  MapProviderReal({
    required LocationService locationService,
    required DirectionsService directionsService,
  }) : _locationService = locationService,
       _directionsService = directionsService {
    DebugLogger.info(_logTag, 'MapProvider constructor called');
    DebugLogger.logSystemInfo();
    DebugLogger.logMapInitialization();
    _initialize();
  }

  // Initialize the provider
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      DebugLogger.info(_logTag, 'Starting initialization...');

      // Check if we're running on Android and log it
      if (Platform.isAndroid) {
        DebugLogger.info(_logTag, 'Running on Android platform');
      } else if (Platform.isIOS) {
        DebugLogger.info(_logTag, 'Running on iOS platform');
      } else {
        DebugLogger.info(_logTag, 'Running on ${Platform.operatingSystem}');
      }

      // Test API connectivity first
      await _testApiConnectivity();

      // Get current location first
      DebugLogger.info(_logTag, 'Requesting current location...');
      _currentLocation = await _locationService.getCurrentLocation();

      if (_currentLocation != null) {
        DebugLogger.info(
          _logTag,
          'Location obtained: ${_currentLocation!.position.latitude}, ${_currentLocation!.position.longitude}',
        );
        DebugLogger.logLocationStatus(true, true, _currentLocation);
      } else {
        DebugLogger.warn(_logTag, 'No location obtained, using fallback');
        DebugLogger.logLocationStatus(false, false, null);
      }

      // Fallback to default location if needed
      if (_currentLocation == null) {
        _currentLocation = LocationUpdate(
          position: const LatLng(-1.2921, 36.8219), // Default to Nairobi, Kenya
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        );
        DebugLogger.info(_logTag, 'Using default location: Nairobi, Kenya');
      }

      // Add current location marker
      _updateCurrentLocationMarker();

      // Start listening to location updates
      _locationSubscription = _locationService.locationStream.listen((
        location,
      ) {
        DebugLogger.debug(
          _logTag,
          'Location update received: ${location.position.latitude}, ${location.position.longitude}',
        );
        _currentLocation = location;
        _updateCurrentLocationMarker();

        // If we're following the user, update the map camera
        if (_trackingMode == MapTrackingMode.followUser &&
            _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(location.position),
          );
        }

        notifyListeners();
      });

      // Load available routes from API
      await fetchAvailableRoutes();

      DebugLogger.info(_logTag, 'Initialization completed successfully');
    } catch (e, stackTrace) {
      DebugLogger.error(
        _logTag,
        'Error initializing MapProvider',
        e,
        stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Test API connectivity
  Future<void> _testApiConnectivity() async {
    try {
      DebugLogger.info(_logTag, 'Testing API connectivity...');
      final routes = await _apiService.getAllRoutes();
      DebugLogger.info(
        _logTag,
        'API test successful - received ${routes.length} routes',
      );
      DebugLogger.logNetworkStatus(
        _apiService.baseUrl,
        true,
        'API responding correctly',
      );
    } catch (e) {
      DebugLogger.error(_logTag, 'API connectivity test failed', e);
      DebugLogger.logNetworkStatus(_apiService.baseUrl, false);
    }
  }

  // Update current location marker
  void _updateCurrentLocationMarker() {
    if (_currentLocation != null) {
      DebugLogger.debug(_logTag, 'Updating current location marker');
      final marker = Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
      );

      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _markers.add(marker);
    }
  }

  // Fetch available routes from the API
  Future<void> fetchAvailableRoutes() async {
    try {
      DebugLogger.info(_logTag, 'Fetching available routes...');

      _availableRoutes = await _apiService.getAllRoutes();

      DebugLogger.info(_logTag, 'Fetched ${_availableRoutes.length} routes');

      // Add route markers to the map
      _addRouteMarkers();

      notifyListeners();
    } catch (e, stackTrace) {
      DebugLogger.error(_logTag, 'Error fetching routes', e, stackTrace);
      notifyListeners();
    }
  }

  // Add markers for all available routes
  void _addRouteMarkers() {
    DebugLogger.debug(
      _logTag,
      'Adding route markers for ${_availableRoutes.length} routes',
    );

    // Remove existing route markers
    _markers.removeWhere(
      (marker) =>
          marker.markerId.value.startsWith('route_start_') ||
          marker.markerId.value.startsWith('route_end_'),
    );

    // Add markers for each route
    for (int i = 0; i < _availableRoutes.length; i++) {
      final route = _availableRoutes[i];

      // Start marker
      final startMarker = Marker(
        markerId: MarkerId('route_start_${route.id}'),
        position: route.startLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '${route.name} - Start',
          snippet:
              'Distance: ${route.distanceInKm}km | Fare: ₹${route.fareAmount}',
        ),
      );

      // End marker
      final endMarker = Marker(
        markerId: MarkerId('route_end_${route.id}'),
        position: route.endLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: '${route.name} - End',
          snippet: route.description,
        ),
      );

      _markers.add(startMarker);
      _markers.add(endMarker);
    }

    DebugLogger.debug(_logTag, 'Added ${_markers.length} markers to map');
  }

  // Fetch nearby routes based on user's location
  Future<List<BusRoute>> fetchNearbyRoutes({double radius = 5.0}) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_currentLocation == null) {
        DebugLogger.warn(
          _logTag,
          'Cannot fetch nearby routes - no current location',
        );
        return [];
      }

      DebugLogger.info(
        _logTag,
        'Fetching nearby routes within ${radius}km radius',
      );

      final nearbyRoutes = await _apiService.getNearbyRoutes(
        _currentLocation!.position.latitude,
        _currentLocation!.position.longitude,
        radius: radius,
      );

      DebugLogger.info(_logTag, 'Found ${nearbyRoutes.length} nearby routes');

      _isLoading = false;
      notifyListeners();

      return nearbyRoutes;
    } catch (e, stackTrace) {
      _isLoading = false;
      DebugLogger.error(_logTag, 'Error fetching nearby routes', e, stackTrace);
      notifyListeners();
      return [];
    }
  }

  // Fetch active routes based on recent updates
  Future<List<dynamic>> fetchActiveRoutes({int hours = 24}) async {
    try {
      _isLoading = true;
      notifyListeners();

      DebugLogger.info(
        _logTag,
        'Fetching active routes from last $hours hours',
      );

      final activeRoutes = await _apiService.getActiveRoutes(hours: hours);

      DebugLogger.info(_logTag, 'Found ${activeRoutes.length} active routes');

      _isLoading = false;
      notifyListeners();

      return activeRoutes;
    } catch (e, stackTrace) {
      _isLoading = false;
      DebugLogger.error(_logTag, 'Error fetching active routes', e, stackTrace);
      notifyListeners();
      return [];
    }
  }

  // Set the map controller
  void setMapController(GoogleMapController controller) {
    DebugLogger.info(_logTag, 'Map controller set');
    _mapController = controller;
    if (_currentLocation != null &&
        _trackingMode == MapTrackingMode.followUser) {
      DebugLogger.debug(_logTag, 'Centering map on user location');
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!.position),
      );
    }
  }

  // Change the tracking mode
  void setTrackingMode(MapTrackingMode mode) {
    DebugLogger.info(_logTag, 'Tracking mode changed to: $mode');
    _trackingMode = mode;

    if (mode == MapTrackingMode.followUser &&
        _currentLocation != null &&
        _mapController != null) {
      DebugLogger.debug(_logTag, 'Following user - updating camera');
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!.position),
      );
    }

    notifyListeners();
  }

  // Start tracking a route
  Future<void> startRouteTracking(BusRoute route) async {
    try {
      DebugLogger.info(_logTag, 'Starting route tracking for: ${route.name}');

      _isRouteActive = true;
      _currentRoute = route;
      _trackingMode = MapTrackingMode.followRoute;

      // Create markers for start and end points
      _markers = {};

      // Start marker
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: route.startLocation,
          infoWindow: InfoWindow(
            title: 'Start: ${route.name}',
            snippet: 'Starting point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // End marker
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: route.endLocation,
          infoWindow: InfoWindow(
            title: 'End: ${route.name}',
            snippet: 'Destination',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Add waypoint markers
      for (int i = 0; i < route.waypoints.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('waypoint$i'),
            position: route.waypoints[i],
            infoWindow: InfoWindow(
              title: 'Stop ${i + 1}',
              snippet: 'Intermediate stop',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }

      DebugLogger.debug(_logTag, 'Getting directions for route');
      // Get directions between all points
      final directions = await _directionsService.getDirections(
        origin: route.startLocation,
        destination: route.endLocation,
        waypoints: route.waypoints,
      );

      if (directions != null) {
        DebugLogger.debug(_logTag, 'Directions received, creating polyline');
        // Add polyline for the route
        _routePolylines = {};
        final polylineCoordinates =
            directions['polylineCoordinates'] as List<LatLng>? ?? [];
        _routePolylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );

        // Fit the map to show the entire route
        if (_mapController != null && polylineCoordinates.isNotEmpty) {
          DebugLogger.debug(_logTag, 'Fitting map bounds to show route');
          // Calculate bounds from polyline coordinates
          double minLat = polylineCoordinates.first.latitude;
          double maxLat = polylineCoordinates.first.latitude;
          double minLng = polylineCoordinates.first.longitude;
          double maxLng = polylineCoordinates.first.longitude;

          for (final point in polylineCoordinates) {
            minLat = math.min(minLat, point.latitude);
            maxLat = math.max(maxLat, point.latitude);
            minLng = math.min(minLng, point.longitude);
            maxLng = math.max(maxLng, point.longitude);
          }

          final bounds = LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          );

          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50),
          );
        }
      } else {
        DebugLogger.warn(_logTag, 'No directions received for route');
      }

      notifyListeners();
      DebugLogger.info(_logTag, 'Route tracking started successfully');
    } catch (e, stackTrace) {
      DebugLogger.error(
        _logTag,
        'Error starting route tracking',
        e,
        stackTrace,
      );
    }
  }

  // Stop tracking the current route
  void stopRouteTracking() {
    DebugLogger.info(_logTag, 'Stopping route tracking');
    _isRouteActive = false;
    _currentRoute = null;
    _routePolylines = {};
    _markers = {};
    _trackingMode = MapTrackingMode.free;
    notifyListeners();
  }

  // Get real-time bus locations for a route
  Future<List<LocationUpdate>> getBusLocationsForRoute(String routeId) async {
    try {
      DebugLogger.debug(_logTag, 'Getting bus locations for route: $routeId');
      return await _apiService.getLocationUpdatesForRoute(routeId);
    } catch (e, stackTrace) {
      DebugLogger.error(_logTag, 'Error getting bus locations', e, stackTrace);
      return [];
    }
  }

  @override
  void dispose() {
    DebugLogger.info(_logTag, 'Disposing MapProvider');
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
