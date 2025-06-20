import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bus_provider.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize mock API service
  final apiService = MockApiService();
  await apiService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => BusProvider()),
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
  bool _isLoading = true;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize both providers
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final busProvider = Provider.of<BusProvider>(context, listen: false);

    // Load saved auth state
    await authProvider.initialize();

    // Load saved bus state if user is authenticated
    if (authProvider.isAuthenticated) {
      await busProvider.loadSavedState();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show splash screen
    if (_showSplash) {
      return SplashScreen(onInitializationComplete: _onSplashComplete);
    }

    // Get auth provider to check authentication state
    final authProvider = Provider.of<AuthProvider>(context);

    // If user is authenticated, show home screen, otherwise show sign in
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const SignInScreen();
    }
  }
}
