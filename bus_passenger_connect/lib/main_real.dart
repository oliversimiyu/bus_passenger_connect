import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/location_service.dart';
import 'services/directions_service.dart';
import 'providers/auth_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/bus_provider.dart';
import 'providers/map_provider_real.dart';
import 'providers/profile_provider.dart';
import 'config/app_config.dart';
import 'screens/home_screen_real.dart';
import 'screens/driver_dashboard_screen.dart';
import 'screens/user_type_selection_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/storage_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize real API service (for future use)
  // final apiService = ApiService();

  // Initialize location service
  final locationService = LocationService();

  // Initialize directions service with API key from config
  final directionsService = DirectionsService(AppConfig.googleMapsApiKey);

  // Create providers
  final authProvider = AuthProvider();
  final driverProvider = DriverProvider();
  final busProvider = BusProvider();

  // Create the real map provider
  final mapProviderReal = MapProviderReal(
    locationService: locationService,
    directionsService: directionsService,
  );

  final profileProvider = ProfileProvider();

  // Initialize auth provider before running the app
  try {
    // Run storage test first (only in debug mode)
    if (kDebugMode) {
      await StorageTest.testStorage();
    }

    await authProvider.initialize();
    await driverProvider.initialize();

    // Sync profile provider with authenticated user
    if (authProvider.isAuthenticated) {
      await profileProvider.syncWithAuthUser(authProvider.currentUser);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing providers: $e');
    }
  }

  runApp(
    MyApp(
      authProvider: authProvider,
      driverProvider: driverProvider,
      busProvider: busProvider,
      mapProviderReal: mapProviderReal,
      profileProvider: profileProvider,
      locationService: locationService,
      directionsService: directionsService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final DriverProvider driverProvider;
  final BusProvider busProvider;
  final MapProviderReal mapProviderReal;
  final ProfileProvider profileProvider;
  final LocationService locationService;
  final DirectionsService directionsService;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.driverProvider,
    required this.busProvider,
    required this.mapProviderReal,
    required this.profileProvider,
    required this.locationService,
    required this.directionsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: driverProvider),
        ChangeNotifierProvider.value(value: busProvider),
        ChangeNotifierProvider.value(value: mapProviderReal),
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: MaterialApp(
        title: 'Bus Passenger Connect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.amber,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        ),
        home: const BusPassengerApp(),
      ),
    );
  }
}

class BusPassengerApp extends StatefulWidget {
  const BusPassengerApp({super.key});

  @override
  State<BusPassengerApp> createState() => _BusPassengerAppState();
}

class _BusPassengerAppState extends State<BusPassengerApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // Simulate a splash screen delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onInitializationComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final driverProvider = Provider.of<DriverProvider>(context);

    if (authProvider.isLoading || driverProvider.isLoading) {
      return SplashScreen(
        onInitializationComplete: () {
          setState(() {
            authProvider.initialize();
            driverProvider.initialize();
          });
        },
      );
    }

    // Check if driver is authenticated
    if (driverProvider.isAuthenticated &&
        driverProvider.currentDriver != null) {
      return DriverDashboardScreen(driver: driverProvider.currentDriver!);
    }

    // Check if passenger is authenticated
    if (authProvider.isAuthenticated) {
      return const HomeScreenReal();
    }

    // No one is authenticated, show user type selection
    return const UserTypeSelectionScreen();
  }
}
