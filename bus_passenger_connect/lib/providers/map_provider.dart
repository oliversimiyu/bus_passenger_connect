import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';
import 'package:bus_passenger_connect/models/location_update.dart';
import 'package:bus_passenger_connect/services/location_service.dart';
import 'package:bus_passenger_connect/services/directions_service.dart';

enum MapTrackingMode { free, followUser, followRoute }

class MapProvider extends ChangeNotifier {
  // Services
  final LocationService _locationService;
  final DirectionsService _directionsService;

  // Current state
  LocationUpdate? _currentLocation;
  BusRoute? _currentRoute;
  Set<Polyline> _routePolylines = {};
  Set<Marker> _markers = {};
  MapTrackingMode _trackingMode = MapTrackingMode.free;
  bool _isRouteActive = false;

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

  MapProvider({
    required LocationService locationService,
    required DirectionsService directionsService,
  }) : _locationService = locationService,
       _directionsService = directionsService {
    _init();
  }

  // Initialize the provider
  Future<void> _init() async {
    try {
      // Get current location
      _currentLocation = await _locationService.getCurrentLocation();

      // Fallback to default location if needed
      if (_currentLocation == null) {
        _currentLocation = LocationUpdate(
          position: const LatLng(-1.2921, 36.8219), // Default to Nairobi, Kenya
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        );
      }

      // Subscribe to location updates
      _locationSubscription = _locationService.locationStream.listen((
        locationUpdate,
      ) {
        _currentLocation = locationUpdate;

        // Update the user's marker
        _updateUserMarker();

        // Center the map on the user if in follow mode
        if (_trackingMode == MapTrackingMode.followUser ||
            _trackingMode == MapTrackingMode.followRoute) {
          _centerOnUser();
        }

        notifyListeners();
      });

      // Set up initial markers
      _updateUserMarker();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing map provider: $e');
      }
      // Set default location as fallback
      _currentLocation = LocationUpdate(
        position: const LatLng(-1.2921, 36.8219), // Default to Nairobi, Kenya
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      );
    }

    notifyListeners();
  }

  // Set the map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    if (kDebugMode) {
      print("Map controller set in MapProvider");
    }

    // Force the map style to ensure proper initialization
    try {
      controller.setMapStyle('[]').catchError((error) {
        if (kDebugMode) {
          print("Error setting map style: $error");
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Exception setting initial map style: $e");
      }
    }

    // Add a small delay to ensure controller is fully initialized
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentLocation != null && _trackingMode != MapTrackingMode.free) {
        _centerOnUser();
      }
    });
  }

  // Set tracking mode
  void setTrackingMode(MapTrackingMode mode) {
    _trackingMode = mode;

    if (mode == MapTrackingMode.followUser ||
        mode == MapTrackingMode.followRoute) {
      _centerOnUser();
    }

    notifyListeners();
  }

  // Center the map on the user's location
  void _centerOnUser() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!.position),
      );
    }
  }

  // Update the user's marker on the map
  void _updateUserMarker() {
    if (_currentLocation != null) {
      final userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: _currentLocation!.position,
        rotation: _currentLocation!.heading,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );

      _markers.removeWhere(
        (marker) => marker.markerId.value == 'user_location',
      );
      _markers.add(userMarker);

      notifyListeners();
    }
  }

  // Add marker to the map
  void addMarker(String id, LatLng position, String title, String type) {
    BitmapDescriptor icon;
    switch (type) {
      case 'landmark':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
        break;
      case 'bus_stop':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        break;
      case 'user':
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
        break;
      default:
        icon = BitmapDescriptor.defaultMarker;
    }

    final marker = Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(title: title),
    );

    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(marker);
    notifyListeners();
  }

  // Start tracking a bus route
  Future<bool> startRouteTracking(BusRoute route) async {
    _currentRoute = route;
    _isRouteActive = true;

    // Create markers for start and end points
    final startMarker = Marker(
      markerId: const MarkerId('route_start'),
      position: route.startLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: 'Start: ${route.name}'),
    );

    final endMarker = Marker(
      markerId: const MarkerId('route_end'),
      position: route.endLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: 'End: ${route.name}'),
    );

    // Add waypoint markers
    Set<Marker> waypointMarkers = {};
    for (int i = 0; i < route.waypoints.length; i++) {
      final waypoint = route.waypoints[i];
      waypointMarkers.add(
        Marker(
          markerId: MarkerId('waypoint_$i'),
          position: waypoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
        ),
      );
    }

    // Update markers
    _markers.removeWhere(
      (marker) =>
          marker.markerId.value == 'route_start' ||
          marker.markerId.value == 'route_end' ||
          marker.markerId.value.startsWith('waypoint_'),
    );

    _markers.add(startMarker);
    _markers.add(endMarker);
    _markers.addAll(waypointMarkers);

    // Get directions for the route
    try {
      final directions = await _directionsService.getDirections(
        origin: route.startLocation,
        destination: route.endLocation,
        waypoints: route.waypoints,
      );

      if (directions != null && directions.containsKey('polylineCoordinates')) {
        List<LatLng> polylineCoordinates = directions['polylineCoordinates'];

        // Create polyline
        final routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );

        _routePolylines.clear();
        _routePolylines.add(routePolyline);

        // Start location tracking
        try {
          await _locationService.startTracking();
        } catch (e) {
          if (kDebugMode) {
            print('Error starting location tracking: $e');
          }
          // Continue with the route even if tracking fails
        }

        // Set tracking mode to follow route
        setTrackingMode(MapTrackingMode.followRoute);

        // Zoom to show the entire route
        if (_mapController != null) {
          LatLngBounds bounds = _getBounds(polylineCoordinates);
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50),
          );
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting directions: $e');
      }
      return false;
    }

    notifyListeners();
    return false;
  }

  // Start location tracking
  Future<void> startLocationTracking() async {
    try {
      await _locationService.initialize();
      await _locationService.startTracking();
      
      if (kDebugMode) {
        print('Location tracking started successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting location tracking: $e');
      }
    }
  }

  // Stop tracking the current route
  void stopRouteTracking() {
    _isRouteActive = false;
    _currentRoute = null;
    _routePolylines.clear();

    // Remove route markers
    _markers.removeWhere(
      (marker) =>
          marker.markerId.value == 'route_start' ||
          marker.markerId.value == 'route_end' ||
          marker.markerId.value.startsWith('waypoint_'),
    );

    // Stop location tracking
    _locationService.stopTracking();

    // Set tracking mode to follow user
    setTrackingMode(MapTrackingMode.followUser);

    notifyListeners();
  }

  // Get bounds for a list of coordinates
  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
