import 'dart:convert';
import '../models/bus.dart';

class QRDataGenerator {
  static String generateMockBusQRData() {
    final mockBus = Bus(
      id: 'BUS123',
      routeNumber: 'Route 42',
      driverName: 'John Doe',
      licensePlate: 'ABC-1234',
      stops: [
        'Downtown Station',
        'Central Park',
        'University Campus',
        'Shopping Mall',
        'Hospital',
        'Business District',
        'Residential Area',
        'Sports Complex',
        'Airport Terminal',
      ],
    );

    return jsonEncode(mockBus.toJson());
  }
}
