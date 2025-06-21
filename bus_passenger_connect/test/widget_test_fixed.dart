// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:bus_passenger_connect/services/location_service.dart';
import 'package:bus_passenger_connect/services/directions_service.dart';
import 'package:bus_passenger_connect/main_real.dart';
import 'package:mockito/mockito.dart';
import 'package:bus_passenger_connect/providers/auth_provider.dart';
import 'package:bus_passenger_connect/providers/bus_provider.dart';
import 'package:bus_passenger_connect/providers/map_provider_real.dart';
import 'package:bus_passenger_connect/providers/profile_provider.dart';

// Simple mock classes for the test
class MockLocationService extends Mock implements LocationService {}

class MockDirectionsService extends Mock implements DirectionsService {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockBusProvider extends Mock implements BusProvider {}

class MockMapProviderReal extends Mock implements MapProviderReal {}

class MockProfileProvider extends Mock implements ProfileProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App navigation smoke test', (WidgetTester tester) async {
    // Create mock services and providers for testing
    final mockLocationService = MockLocationService();
    final mockDirectionsService = MockDirectionsService();
    final mockAuthProvider = MockAuthProvider();
    final mockBusProvider = MockBusProvider();
    final mockMapProviderReal = MockMapProviderReal();
    final mockProfileProvider = MockProfileProvider();

    // Mock authentication state
    when(mockAuthProvider.isAuthenticated).thenReturn(false);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        locationService: mockLocationService,
        directionsService: mockDirectionsService,
        authProvider: mockAuthProvider,
        busProvider: mockBusProvider,
        mapProviderReal: mockMapProviderReal,
        profileProvider: mockProfileProvider,
      ),
    );

    // Wait for the app to stabilize
    await tester.pumpAndSettle();

    // Verify app title appears (will be on the splash or login screen)
    expect(find.textContaining('Bus Passenger Connect'), findsOneWidget);
  });
}
