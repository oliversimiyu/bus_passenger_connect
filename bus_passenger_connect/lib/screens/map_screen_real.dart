import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bus_passenger_connect/providers/map_provider_real.dart';
import 'package:bus_passenger_connect/config/app_config.dart';
import 'package:bus_passenger_connect/models/bus_route.dart';
import 'package:bus_passenger_connect/screens/debug_screen.dart';
import 'package:bus_passenger_connect/utils/debug_logger.dart';
import 'dart:io' show Platform;
import 'dart:async';

// Import the enum from the provider
export 'package:bus_passenger_connect/providers/map_provider_real.dart'
    show MapTrackingMode;

class MapScreenReal extends StatefulWidget {
  const MapScreenReal({super.key});

  @override
  State<MapScreenReal> createState() => _MapScreenRealState();
}

class _MapScreenRealState extends State<MapScreenReal> {
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(
      AppConfig.defaultLatitude,
      AppConfig.defaultLongitude,
    ), // Default to Nairobi, Kenya
    zoom: AppConfig.defaultZoom,
  );

  final bool _mapError = false;
  final String _errorMessage = "Unable to load map";
  final Completer<GoogleMapController> _controllerCompleter =
      Completer<GoogleMapController>();
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    DebugLogger.info('MapScreen', 'MapScreen initialized');
    DebugLogger.info(
      'MapScreen',
      'API key configured: ${AppConfig.googleMapsApiKey.isNotEmpty}',
    );
    DebugLogger.info(
      'MapScreen',
      'Default location: ${AppConfig.defaultLatitude}, ${AppConfig.defaultLongitude}',
    );

    if (Platform.isAndroid) {
      DebugLogger.info('MapScreen', 'Running on Android');
    } else if (Platform.isIOS) {
      DebugLogger.info('MapScreen', 'Running on iOS');
    } else {
      DebugLogger.info('MapScreen', 'Running on ${Platform.operatingSystem}');
    }

    // Initialize map provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = Provider.of<MapProviderReal>(context, listen: false);
      if (kDebugMode) {
        print("MapScreen: Initializing map provider...");
      }

      // The provider should already be initialized from main.dart, but let's make sure
      if (mapProvider.currentLocation != null) {
        if (kDebugMode) {
          print(
            "MapScreen: Current location available: ${mapProvider.currentLocation!.position}",
          );
        }
      } else {
        if (kDebugMode) {
          print("MapScreen: No current location available, will use default");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Map'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildActiveRouteCard(),
          _buildLocationButton(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMap() {
    if (_mapError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: Colors.red.shade400, size: 80),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return Consumer<MapProviderReal>(
      builder: (context, mapProvider, child) {
        // Determine initial camera position based on current location
        CameraPosition initialPosition = _initialCameraPosition;
        if (mapProvider.currentLocation != null) {
          initialPosition = CameraPosition(
            target: mapProvider.currentLocation!.position,
            zoom: AppConfig.defaultZoom,
          );
        }

        return GoogleMap(
          initialCameraPosition: initialPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          polylines: mapProvider.routePolylines,
          markers: mapProvider.markers,
          onMapCreated: (GoogleMapController controller) {
            if (!_controllerCompleter.isCompleted) {
              _controllerCompleter.complete(controller);
              mapProvider.setMapController(controller);
              setState(() {
                _isMapCreated = true;
              });

              // Move camera to current location if available
              if (mapProvider.currentLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    mapProvider.currentLocation!.position,
                    AppConfig.defaultZoom,
                  ),
                );
              }

              if (kDebugMode) {
                print("MapScreen: Map created successfully");
                print(
                  "MapScreen: Markers count: ${mapProvider.markers.length}",
                );
                print(
                  "MapScreen: Polylines count: ${mapProvider.routePolylines.length}",
                );
              }
            }
          },
          onCameraMove: (_) {
            // Stop following user if the map is moved manually
            if (mapProvider.trackingMode == MapTrackingMode.followUser) {
              mapProvider.setTrackingMode(MapTrackingMode.free);
            }
          },
        );
      },
    );
  }

  Widget _buildActiveRouteCard() {
    return Consumer<MapProviderReal>(
      builder: (context, mapProvider, child) {
        if (mapProvider.isRouteActive && mapProvider.currentRoute != null) {
          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<MapProviderReal>(
      builder: (context, mapProvider, child) {
        // Only show the routes button if no route is active
        if (!mapProvider.isRouteActive) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Debug button (only in debug mode)
              if (kDebugMode)
                FloatingActionButton(
                  mini: true,
                  heroTag: "debug_button",
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  onPressed: () {
                    DebugLogger.info(
                      'MapScreen',
                      'Debug screen accessed by user',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebugScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.bug_report),
                ),
              if (kDebugMode) const SizedBox(height: 8),
              // Main routes button
              FloatingActionButton.extended(
                heroTag: "routes_button",
                onPressed: () {
                  _showRoutesBottomSheet(context);
                },
                label: const Text('Routes'),
                icon: const Icon(Icons.directions_bus),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLocationButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: Consumer<MapProviderReal>(
        builder: (context, mapProvider, child) {
          return FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            onPressed: () async {
              if (mapProvider.currentLocation != null && _isMapCreated) {
                final controller = await _controllerCompleter.future;
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    mapProvider.currentLocation!.position,
                    AppConfig.defaultZoom,
                  ),
                );
                mapProvider.setTrackingMode(MapTrackingMode.followUser);
              }
            },
            child: const Icon(Icons.my_location),
          );
        },
      ),
    );
  }

  void _showRoutesBottomSheet(BuildContext context) {
    final mapProvider = Provider.of<MapProviderReal>(context, listen: false);

    // Fetch routes if not already loaded
    if (mapProvider.availableRoutes.isEmpty) {
      mapProvider.fetchAvailableRoutes();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DefaultTabController(
          length: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bus Routes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const TabBar(
                  tabs: [
                    Tab(text: 'All Routes'),
                    Tab(text: 'Nearby'),
                    Tab(text: 'Active'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAllRoutesTab(),
                      _buildNearbyRoutesTab(),
                      _buildActiveRoutesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllRoutesTab() {
    return Consumer<MapProviderReal>(
      builder: (context, mapProvider, child) {
        if (mapProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (mapProvider.availableRoutes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Routes Available',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    mapProvider.fetchAvailableRoutes();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: mapProvider.availableRoutes.length,
          itemBuilder: (context, index) {
            final route = mapProvider.availableRoutes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(route.name),
                subtitle: Text(route.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${route.distanceInKm} km'),
                    Text('₹ ${route.fareAmount}'),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await mapProvider.startRouteTracking(route);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNearbyRoutesTab() {
    return FutureBuilder<List<BusRoute>>(
      future: Provider.of<MapProviderReal>(
        context,
        listen: false,
      ).fetchNearbyRoutes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error loading nearby routes',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {}); // Refresh the future
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final nearbyRoutes = snapshot.data ?? [];

        if (nearbyRoutes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No Nearby Routes Found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search radius or location',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: nearbyRoutes.length,
          itemBuilder: (context, index) {
            final route = nearbyRoutes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(route.name),
                subtitle: Text(route.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${route.distanceInKm} km'),
                    Text('₹ ${route.fareAmount}'),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Provider.of<MapProviderReal>(
                    context,
                    listen: false,
                  ).startRouteTracking(route);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveRoutesTab() {
    return FutureBuilder<List<dynamic>>(
      future: Provider.of<MapProviderReal>(
        context,
        listen: false,
      ).fetchActiveRoutes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error loading active routes',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {}); // Refresh the future
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final activeRoutes = snapshot.data ?? [];

        if (activeRoutes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus_filled_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Active Routes Found',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for real-time bus activity',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: activeRoutes.length,
          itemBuilder: (context, index) {
            final routeData = activeRoutes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(routeData['name'] ?? 'Unknown Route'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routeData['description'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      '${routeData['busCount'] ?? 0} buses active | ${routeData['updateCount'] ?? 0} updates',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${routeData['distanceInKm'] ?? 0} km'),
                    Text('₹ ${routeData['fareAmount'] ?? 0}'),
                  ],
                ),
                onTap: () async {
                  // Convert to BusRoute object
                  final route = BusRoute(
                    id: routeData['routeId'] ?? '',
                    name: routeData['name'] ?? 'Unknown Route',
                    description: routeData['description'] ?? '',
                    startLocation: LatLng(
                      routeData['startLocation']?['latitude'] ?? 0.0,
                      routeData['startLocation']?['longitude'] ?? 0.0,
                    ),
                    endLocation: LatLng(
                      routeData['endLocation']?['latitude'] ?? 0.0,
                      routeData['endLocation']?['longitude'] ?? 0.0,
                    ),
                    waypoints: const [],
                    distanceInKm: routeData['distanceInKm']?.toDouble() ?? 0.0,
                    estimatedTimeInMinutes:
                        routeData['estimatedTimeInMinutes'] ?? 0,
                    fareAmount: routeData['fareAmount']?.toDouble() ?? 0.0,
                    isActive: true,
                    schedule: const [],
                  );

                  Navigator.pop(context);
                  await Provider.of<MapProviderReal>(
                    context,
                    listen: false,
                  ).startRouteTracking(route);
                },
              ),
            );
          },
        );
      },
    );
  }
}
