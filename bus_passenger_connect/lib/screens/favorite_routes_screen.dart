import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/map_provider_real.dart';
import '../utils/sample_routes.dart';
import '../models/bus_route.dart';
import 'map_screen_real.dart';

class FavoriteRoutesScreen extends StatelessWidget {
  const FavoriteRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Routes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final userProfile = profileProvider.userProfile;

          if (userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProfile.favoriteRouteIds.isEmpty) {
            return _buildEmptyState();
          }

          // Get all sample routes
          final allRoutes = SampleRoutes.getRoutes();

          // Filter for favorites
          final favoriteRoutes = allRoutes
              .where((route) => userProfile.favoriteRouteIds.contains(route.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteRoutes.length,
            itemBuilder: (context, index) {
              final route = favoriteRoutes[index];
              return _buildRouteCard(context, route, profileProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Favorite Routes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add routes to favorites for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    BusRoute route,
    ProfileProvider profileProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeFavorite(context, route, profileProvider),
                  child: const Icon(Icons.star, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              route.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${route.estimatedTimeInMinutes} min',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${route.distanceInKm} km',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _navigateToRoute(context, route),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text('View Map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removeFavorite(
    BuildContext context,
    BusRoute route,
    ProfileProvider profileProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text('Remove "${route.name}" from your favorite routes?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              profileProvider.removeFavoriteRoute(route.id);
              Navigator.of(ctx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${route.name} removed from favorites')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(BuildContext context, BusRoute route) {
    final mapProvider = Provider.of<MapProviderReal>(context, listen: false);

    // Navigate to the map screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreenReal()),
    );

    // Start tracking the selected route
    // This is executed after navigation to ensure MapProviderReal is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapProvider.startRouteTracking(route);
    });
  }
}
