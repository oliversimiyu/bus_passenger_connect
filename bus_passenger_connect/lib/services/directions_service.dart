import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  final String _apiKey; // Your Google Maps API key
  bool _useSimulation = false;

  DirectionsService(this._apiKey) {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      if (kDebugMode) {
        print(
          'Warning: Google Maps API key is not configured properly. Using simulated data.',
        );
      }
      _useSimulation = true;
    }
  }

  // Get directions between two points
  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    // If simulation mode is active, return simulated directions
    if (_useSimulation) {
      return _getSimulatedDirections(origin, destination, waypoints);
    }

    try {
      // Build waypoints string if provided
      String waypointString = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        waypointString = 'waypoints=optimize:true';
        for (var point in waypoints) {
          waypointString += '|${point.latitude},${point.longitude}';
        }
        waypointString += '&';
      }

      // Build the URL for the directions API
      final url =
          '$_baseUrl?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          '$waypointString'
          'mode=driving&'
          'key=$_apiKey';

      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Extract route data
          final routes = data['routes'];
          if (routes is List && routes.isNotEmpty) {
            final route = routes[0];
            final legs = route['legs'];

            // Total distance and duration
            int totalDistance = 0;
            int totalDuration = 0;

            if (legs is List && legs.isNotEmpty) {
              for (var leg in legs) {
                if (leg != null &&
                    leg['distance'] != null &&
                    leg['distance']['value'] != null &&
                    leg['duration'] != null &&
                    leg['duration']['value'] != null) {
                  totalDistance += leg['distance']['value'] as int;
                  totalDuration += leg['duration']['value'] as int;
                }
              }
            }

            // Get encoded polyline
            final polyline = route['overview_polyline']?['points'];
            if (polyline == null) {
              if (kDebugMode) {
                print('Polyline data is missing from the API response');
              }
              return null;
            }

            // Decode polyline
            List<LatLng> polylineCoordinates = [];
            PolylinePoints polylinePoints = PolylinePoints();
            List<PointLatLng> decodedPolyline = polylinePoints.decodePolyline(
              polyline,
            );

            for (var point in decodedPolyline) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }

            // Return the processed data
            return {
              'polylineCoordinates': polylineCoordinates,
              'distanceInMeters': totalDistance,
              'distanceText':
                  legs.isNotEmpty && legs[0]?['distance']?['text'] != null
                  ? legs[0]['distance']['text']
                  : '$totalDistance m',
              'durationInSeconds': totalDuration,
              'durationText':
                  legs.isNotEmpty && legs[0]?['duration']?['text'] != null
                  ? legs[0]['duration']['text']
                  : '${(totalDuration / 60).round()} min',
              'startAddress':
                  legs.isNotEmpty && legs[0]?['start_address'] != null
                  ? legs[0]['start_address']
                  : 'Start',
              'endAddress': legs.isNotEmpty && legs[0]?['end_address'] != null
                  ? legs[0]['end_address']
                  : 'End',
              'steps': legs.isNotEmpty && legs[0]?['steps'] != null
                  ? legs[0]['steps']
                  : [],
            };
          }
        } else {
          if (kDebugMode) {
            print('Error from Google Directions API: ${data['status']}');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print(
            'Failed to get directions. Status code: ${response.statusCode}',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting directions: $e');
      }
      // Fall back to simulated directions on error
      return _getSimulatedDirections(origin, destination, waypoints);
    }

    return null;
  }

  // Generate simulated directions data for testing without API key
  Map<String, dynamic> _getSimulatedDirections(
    LatLng origin,
    LatLng destination,
    List<LatLng>? waypoints,
  ) {
    // Create a straight-line path between origin and destination
    final List<LatLng> points = _generatePathBetweenPoints(origin, destination);

    // Calculate a rough distance and duration
    final double distanceInMeters = _calculateDistance(origin, destination);
    final int durationInSeconds = (distanceInMeters / 10)
        .round(); // Assume 10 m/s speed

    // Return the processed data in the same format as the API response
    return {
      'polylineCoordinates': points,
      'distanceInMeters': distanceInMeters.round(),
      'distanceText': '${(distanceInMeters / 1000).toStringAsFixed(1)} km',
      'durationInSeconds': durationInSeconds,
      'durationText': '${(durationInSeconds / 60).round()} min',
      'startAddress': 'Simulated Start',
      'endAddress': 'Simulated Destination',
      'steps': [],
    };
  }

  // Generate a path between two points with some intermediate waypoints
  List<LatLng> _generatePathBetweenPoints(LatLng start, LatLng end) {
    final List<LatLng> points = [start];

    // Add some intermediate points to make the path look more realistic
    final int steps = 8;
    final double latStep = (end.latitude - start.latitude) / steps;
    final double lngStep = (end.longitude - start.longitude) / steps;

    // Add slight variations to make the path more natural
    for (int i = 1; i < steps; i++) {
      final double offsetLat = (i % 2 == 0) ? 0.0002 : -0.0002;
      final double offsetLng = (i % 3 == 0) ? 0.0003 : -0.0001;

      points.add(
        LatLng(
          start.latitude + (latStep * i) + offsetLat,
          start.longitude + (lngStep * i) + offsetLng,
        ),
      );
    }

    points.add(end);
    return points;
  }

  // Calculate rough distance between two coordinates in meters
  double _calculateDistance(LatLng start, LatLng end) {
    // Very simplified distance calculation
    const double earthRadius = 6371000; // meters
    final double lat1 = start.latitude * (pi / 180);
    final double lat2 = end.latitude * (pi / 180);
    final double lon1 = start.longitude * (pi / 180);
    final double lon2 = end.longitude * (pi / 180);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
