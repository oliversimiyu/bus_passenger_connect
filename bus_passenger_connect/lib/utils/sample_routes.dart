import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';

class SampleRoutes {
  // Sample bus routes for testing - Kenya locations
  static List<BusRoute> getRoutes() {
    return [
      BusRoute(
        id: '1',
        name: 'Nairobi City Express',
        description: 'Express route connecting Westlands to Nairobi CBD',
        waypoints: [
          const LatLng(-1.2747, 36.8085), // Intermediate stop - Parklands
          const LatLng(
            -1.2819,
            36.8184,
          ), // Intermediate stop - University of Nairobi
          const LatLng(-1.2880, 36.8208), // Intermediate stop - Central Park
        ],
        startLocation: const LatLng(
          -1.2641,
          36.8028,
        ), // Start point - Westlands
        endLocation: const LatLng(-1.2921, 36.8219), // End point - CBD
        distanceInKm: 7.8,
        estimatedTimeInMinutes: 35,
      ),
      BusRoute(
        id: '2',
        name: 'Karen - Langata Line',
        description:
            'Route connecting Karen and Langata residential areas to the city',
        waypoints: [
          const LatLng(
            -1.3201,
            36.7834,
          ), // Intermediate stop - Karen Shopping Center
          const LatLng(-1.3233, 36.7953), // Intermediate stop - Hardy
          const LatLng(-1.3152, 36.8036), // Intermediate stop - Langata
        ],
        startLocation: const LatLng(-1.3278, 36.7437), // Start point - Karen
        endLocation: const LatLng(-1.2921, 36.8219), // End point - CBD
        distanceInKm: 14.2,
        estimatedTimeInMinutes: 55,
      ),
      BusRoute(
        id: '3',
        name: 'Eastlands Connect',
        description: 'Route serving the Eastern suburbs to Nairobi Central',
        waypoints: [
          const LatLng(-1.2895, 36.8754), // Intermediate stop - Buruburu
          const LatLng(-1.2921, 36.8654), // Intermediate stop - Makadara
          const LatLng(-1.2914, 36.8432), // Intermediate stop - Gikomba
        ],
        startLocation: const LatLng(-1.2601, 36.9290), // Start point - Utawala
        endLocation: const LatLng(-1.2921, 36.8219), // End point - CBD
        distanceInKm: 16.5,
        estimatedTimeInMinutes: 65,
      ),
      BusRoute(
        id: '4',
        name: 'University Route',
        description: 'Connects major universities and colleges around Nairobi',
        waypoints: [
          const LatLng(
            -1.2662,
            36.7414,
          ), // Intermediate stop - Strathmore University
          const LatLng(-1.2784, 36.7650), // Intermediate stop - Upper Hill
          const LatLng(
            -1.2819,
            36.8184,
          ), // Intermediate stop - University of Nairobi
        ],
        startLocation: const LatLng(
          -1.2246,
          36.6851,
        ), // Start point - Jomo Kenyatta University
        endLocation: const LatLng(
          -1.3051,
          36.9052,
        ), // End point - Kenyatta University
        distanceInKm: 30.1,
        estimatedTimeInMinutes: 90,
      ),
      BusRoute(
        id: '5',
        name: 'Juja - CBD Express',
        description: 'Fast route connecting Juja to Nairobi CBD',
        waypoints: [
          const LatLng(-1.1410, 37.0135), // Intermediate stop - Thika Road Mall
          const LatLng(-1.2199, 36.8892), // Intermediate stop - Roysambu
          const LatLng(-1.2554, 36.8555), // Intermediate stop - Pangani
        ],
        startLocation: const LatLng(-1.1022, 37.0147), // Start point - Juja
        endLocation: const LatLng(-1.2921, 36.8219), // End point - CBD
        distanceInKm: 26.8,
        estimatedTimeInMinutes: 80,
      ),
    ];
  }
}
