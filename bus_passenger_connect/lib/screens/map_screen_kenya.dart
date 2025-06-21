import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bus_passenger_connect/providers/map_provider.dart';
import 'package:bus_passenger_connect/utils/sample_routes.dart';
import 'package:bus_passenger_connect/config/app_config.dart';
import 'dart:async';

class MapScreenKenya extends StatefulWidget {
  const MapScreenKenya({Key? key}) : super(key: key);

  @override
  State<MapScreenKenya> createState() => _MapScreenKenyaState();
}

class _MapScreenKenyaState extends State<MapScreenKenya> {
  // Kenya-specific coordinates for Nairobi city center
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-1.2921, 36.8219), // Nairobi, Kenya
    zoom: 15.0,
  );

  bool _mapError = false;
  String _errorMessage = "Loading map...";
  Completer<GoogleMapController> _controllerCompleter = Completer<GoogleMapController>();
  bool _locationPermissionGranted = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeMapAndLocation();
  }

  Future<void> _initializeMapAndLocation() async {
    if (kDebugMode) {
      print("Initializing map with Kenya coordinates: -1.2921, 36.8219");
      print("Google Maps API Key: ${AppConfig.googleMapsApiKey}");
    }

    // Check and request location permissions
    await _checkLocationPermissions();
    
    // Initialize location tracking
    _initializeLocationTracking();
    
    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled.');
        }
        setState(() {
          _errorMessage = "Location services are disabled. Please enable location services.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          setState(() {
            _errorMessage = "Location permission denied. The app will use default Kenya location.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        setState(() {
          _errorMessage = "Location permissions permanently denied. Please enable in settings.";
        });
        return;
      }

      setState(() {
        _locationPermissionGranted = true;
      });
      
      if (kDebugMode) {
        print('Location permission granted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location permissions: $e');
      }
    }
  }

  void _initializeLocationTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProvider>(context, listen: false);
      
      // Start location tracking
      try {
        mapProvider.startLocationTracking();
        if (kDebugMode) {
          print('Location tracking started');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error starting location tracking: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transit Map - Kenya'),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing map for Kenya...'),
              Text('Requesting location permissions...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transit Map - Kenya'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              final mapProvider = Provider.of<MapProvider>(context, listen: false);
              
              if (_locationPermissionGranted) {
                try {
                  // Get current location and move camera
                  Position position = await Geolocator.getCurrentPosition();
                  final controller = await _controllerCompleter.future;
                  await controller.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(position.latitude, position.longitude),
                    ),
                  );
                  mapProvider.setTrackingMode(MapTrackingMode.followUser);
                  
                  if (kDebugMode) {
                    print('Moved to current location: ${position.latitude}, ${position.longitude}');
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('Error getting current location: $e');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to get current location. Using Kenya default.'),
                    ),
                  );
                  // Fall back to Kenya default
                  final controller = await _controllerCompleter.future;
                  await controller.animateCamera(
                    CameraUpdate.newLatLng(const LatLng(-1.2921, 36.8219)),
                  );
                }
              } else {
                // Use Kenya default location
                final controller = await _controllerCompleter.future;
                await controller.animateCamera(
                  CameraUpdate.newLatLng(const LatLng(-1.2921, 36.8219)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Using default Kenya location (Nairobi)'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _mapError = false;
                _errorMessage = "Loading map...";
              });
              _initializeMapAndLocation();
            },
          ),
        ],
      ),
      body: Stack(children: [_buildMap(), _buildRoutePanel()]),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMap() {
    if (_mapError) {
      return _buildMapErrorView();
    }

    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        if (kDebugMode) {
          print("Building Google Map with Kenya focus");
        }

        return GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: false, // We use custom button
          mapToolbarEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: false, // Use custom zoom controls
          mapType: MapType.normal,
          markers: mapProvider.markers,
          polylines: mapProvider.routePolylines,
          onMapCreated: (GoogleMapController controller) async {
            if (kDebugMode) {
              print("Google Map created successfully for Kenya");
            }

            // Complete the controller completer
            if (!_controllerCompleter.isCompleted) {
              _controllerCompleter.complete(controller);
            }

            // Register controller with provider
            mapProvider.setMapController(controller);

            // Add Kenya-specific markers (Nairobi landmarks)
            _addKenyaLandmarks(mapProvider);

            // Move camera to Kenya with a delay to ensure map is loaded
            await Future.delayed(const Duration(milliseconds: 1000));
            
            try {
              await controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: LatLng(-1.2921, 36.8219), // Nairobi CBD
                    zoom: 15.0,
                  ),
                ),
              );
              
              if (kDebugMode) {
                print("Camera moved to Nairobi, Kenya");
              }

              // If location permission granted, try to get current location
              if (_locationPermissionGranted) {
                try {
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  
                  // Only move to current location if it's in Kenya (rough bounds)
                  if (position.latitude >= -5.0 && position.latitude <= 5.0 &&
                      position.longitude >= 33.0 && position.longitude <= 42.0) {
                    await Future.delayed(const Duration(milliseconds: 500));
                    await controller.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(position.latitude, position.longitude),
                      ),
                    );
                    if (kDebugMode) {
                      print("Moved to current location in Kenya: ${position.latitude}, ${position.longitude}");
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print("Could not get current location: $e");
                  }
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print("Error setting up map: $e");
              }
              setState(() {
                _mapError = true;
                _errorMessage = "Error loading Kenya map: $e";
              });
            }
          },
          onCameraMove: (CameraPosition position) {
            // Optional: Track camera movements
          },
          onTap: (LatLng position) {
            if (kDebugMode) {
              print("Map tapped at: ${position.latitude}, ${position.longitude}");
            }
          },
        );
      },
    );
  }

  void _addKenyaLandmarks(MapProvider mapProvider) {
    // Add some key landmarks in Nairobi for reference
    final landmarks = [
      {
        'id': 'nairobi_cbd',
        'name': 'Nairobi CBD',
        'position': const LatLng(-1.2921, 36.8219),
      },
      {
        'id': 'jkia',
        'name': 'Jomo Kenyatta International Airport',
        'position': const LatLng(-1.3192, 36.9278),
      },
      {
        'id': 'westlands',
        'name': 'Westlands',
        'position': const LatLng(-1.2641, 36.8028),
      },
      {
        'id': 'karen',
        'name': 'Karen',
        'position': const LatLng(-1.3278, 36.7437),
      },
    ];

    for (var landmark in landmarks) {
      mapProvider.addMarker(
        landmark['id'] as String,
        landmark['position'] as LatLng,
        landmark['name'] as String,
        'landmark',
      );
    }
  }

  Widget _buildMapErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Map Error",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry Map"),
                onPressed: () {
                  setState(() {
                    _mapError = false;
                    _errorMessage = "Loading map...";
                  });
                  _initializeMapAndLocation();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text("Check Location Settings"),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Open App Settings"),
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Default location: Nairobi, Kenya",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        // Show active route information if a route is active
        if (mapProvider.isRouteActive && mapProvider.currentRoute != null) {
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapProvider.currentRoute!.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mapProvider.currentRoute!.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.route, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('${mapProvider.currentRoute!.distanceInKm} km'),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '${mapProvider.currentRoute!.estimatedTimeInMinutes} min',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        mapProvider.stopRouteTracking();
                      },
                      child: const Text('End Route Tracking'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        if (!mapProvider.isRouteActive) {
          return FloatingActionButton(
            onPressed: () => _showRoutesBottomSheet(context),
            child: const Icon(Icons.directions_bus),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showRoutesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final routes = SampleRoutes.getRoutes();
        return Consumer<MapProvider>(
          builder: (context, mapProvider, child) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Available Routes in Kenya',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(route.name),
                          subtitle: Text(route.description),
                          trailing: Text('${route.distanceInKm} km'),
                          onTap: () async {
                            Navigator.pop(context);
                            await mapProvider.startRouteTracking(route);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
