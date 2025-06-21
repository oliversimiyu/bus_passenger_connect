import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationUpdate {
  final LatLng position;
  final double speed; // in km/h
  final double heading; // in degrees
  final DateTime timestamp;

  LocationUpdate({
    required this.position,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      position: LatLng(json['lat'], json['lng']),
      speed: json['speed'],
      heading: json['heading'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
