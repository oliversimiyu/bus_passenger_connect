class Bus {
  final String id;
  final String routeNumber;
  final String driverName;
  final String licensePlate;
  final List<String> stops;

  Bus({
    required this.id,
    required this.routeNumber,
    required this.driverName,
    required this.licensePlate,
    required this.stops,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      routeNumber: json['routeNumber'],
      driverName: json['driverName'],
      licensePlate: json['licensePlate'],
      stops: List<String>.from(json['stops']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeNumber': routeNumber,
      'driverName': driverName,
      'licensePlate': licensePlate,
      'stops': stops,
    };
  }
}
