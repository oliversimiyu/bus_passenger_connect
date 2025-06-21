import 'package:google_maps_flutter/google_maps_flutter.dart';

class Schedule {
  final String day;
  final String departureTime;

  Schedule({required this.day, required this.departureTime});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day'] ?? '',
      departureTime: json['departureTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'departureTime': departureTime};
  }
}

class BusRoute {
  final String id;
  final String name;
  final String description;
  final List<LatLng> waypoints;
  final LatLng startLocation;
  final LatLng endLocation;
  final double distanceInKm;
  final int estimatedTimeInMinutes;
  final double fareAmount;
  final bool isActive;
  final List<Schedule> schedule;

  BusRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.waypoints,
    required this.startLocation,
    required this.endLocation,
    required this.distanceInKm,
    required this.estimatedTimeInMinutes,
    this.fareAmount = 0.0,
    this.isActive = true,
    this.schedule = const [],
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id or regular id
    final id = json['_id'] ?? json['id'] ?? '';

    // Process waypoints
    List<LatLng> waypointsList = [];
    if (json['waypoints'] != null) {
      for (var point in json['waypoints']) {
        // Handle both formats (backend vs original)
        if (point is Map) {
          final lat = point['latitude'] ?? point['lat'] ?? 0.0;
          final lng = point['longitude'] ?? point['lng'] ?? 0.0;
          waypointsList.add(
            LatLng(
              lat is int ? lat.toDouble() : lat,
              lng is int ? lng.toDouble() : lng,
            ),
          );
        }
      }
    }

    // Process start location
    final startLoc = json['startLocation'] ?? {};
    final startLat = startLoc['latitude'] ?? startLoc['lat'] ?? 0.0;
    final startLng = startLoc['longitude'] ?? startLoc['lng'] ?? 0.0;

    // Process end location
    final endLoc = json['endLocation'] ?? {};
    final endLat = endLoc['latitude'] ?? endLoc['lat'] ?? 0.0;
    final endLng = endLoc['longitude'] ?? endLoc['lng'] ?? 0.0;

    // Process schedule
    List<Schedule> scheduleList = [];
    if (json['schedule'] != null) {
      for (var s in json['schedule']) {
        scheduleList.add(Schedule.fromJson(s));
      }
    }

    return BusRoute(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      waypoints: waypointsList,
      startLocation: LatLng(
        startLat is int ? startLat.toDouble() : startLat,
        startLng is int ? startLng.toDouble() : startLng,
      ),
      endLocation: LatLng(
        endLat is int ? endLat.toDouble() : endLat,
        endLng is int ? endLng.toDouble() : endLng,
      ),
      distanceInKm: (json['distanceInKm'] ?? 0.0) is int
          ? (json['distanceInKm'] as int).toDouble()
          : json['distanceInKm'] ?? 0.0,
      estimatedTimeInMinutes: json['estimatedTimeInMinutes'] ?? 0,
      fareAmount: (json['fareAmount'] ?? 0.0) is int
          ? (json['fareAmount'] as int).toDouble()
          : json['fareAmount'] ?? 0.0,
      isActive: json['isActive'] ?? true,
      schedule: scheduleList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> waypointsJson = [];
    for (var point in waypoints) {
      waypointsJson.add({
        'latitude': point.latitude,
        'longitude': point.longitude,
      });
    }

    List<Map<String, dynamic>> scheduleJson = [];
    for (var s in schedule) {
      scheduleJson.add(s.toJson());
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'waypoints': waypointsJson,
      'startLocation': {
        'latitude': startLocation.latitude,
        'longitude': startLocation.longitude,
      },
      'endLocation': {
        'latitude': endLocation.latitude,
        'longitude': endLocation.longitude,
      },
      'distanceInKm': distanceInKm,
      'estimatedTimeInMinutes': estimatedTimeInMinutes,
      'fareAmount': fareAmount,
      'isActive': isActive,
      'schedule': scheduleJson,
    };
  }
}
