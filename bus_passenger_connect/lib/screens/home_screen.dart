import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bus_provider.dart';
import '../widgets/alert_confirmation_animation.dart';
import '../widgets/stop_search_delegate.dart';
import '../widgets/map_navigation_button.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'qr_display_screen.dart';
import 'map_screen_real.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Passenger Connect'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Consumer<BusProvider>(
        builder: (context, busProvider, child) {
          if (busProvider.isOnBus) {
            return _buildBusInfo(context, busProvider);
          } else {
            return _buildNoBusScreen(context);
          }
        },
      ),
    );
  }

  Widget _buildNoBusScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_outlined,
              size: 100,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Not currently on a bus',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Scan a QR code to board a bus',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate Test QR Code'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QRDisplayScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const MapNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildBusInfo(BuildContext context, BusProvider busProvider) {
    final bus = busProvider.currentBus!;
    final isAlertTriggered = busProvider.alertTriggered;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_bus,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Currently on Bus',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _infoRow(context, 'Route', bus.routeNumber, Icons.route),
                  _infoRow(context, 'Driver', bus.driverName, Icons.person),
                  _infoRow(
                    context,
                    'License Plate',
                    bus.licensePlate,
                    Icons.badge,
                  ),
                ],
              ),
            ),
          ),

          // Bus Stops header with search functionality
          _buildBusStopsHeader(context, busProvider),

          const SizedBox(height: 10),

          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                itemCount: bus.stops.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final stop = bus.stops[index];
                  final isSelected = stop == busProvider.selectedStop;

                  return ListTile(
                    title: Text(
                      stop,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      busProvider.selectStop(stop);
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (busProvider.selectedStop != null && !isAlertTriggered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications_active),
                label: Text('Alert driver for ${busProvider.selectedStop}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  busProvider.triggerAlert();
                  _showAlertConfirmation(context, busProvider);
                },
              ),
            ),

          if (isAlertTriggered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  busProvider.cancelAlert();
                },
              ),
            ),

          const SizedBox(height: 10),

          // Bus Exit and Map buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _confirmExitBus(context, busProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Exit Bus'),
                ),
              ),
              const SizedBox(width: 10),                ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MapScreenReal(),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Track Route'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Create widget for the Bus Stops header with search button
  Widget _buildBusStopsHeader(BuildContext context, BusProvider busProvider) {
    final bus = busProvider.currentBus!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bus Stops',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (busProvider.selectedStop != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'Selected: ${busProvider.selectedStop}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedStop = await showSearch<String?>(
                  context: context,
                  delegate: StopSearchDelegate(
                    stops: bus.stops,
                    selectedStop: busProvider.selectedStop,
                  ),
                );

                if (selectedStop != null) {
                  busProvider.selectStop(selectedStop);
                }
              },
              tooltip: 'Search stops',
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showAlertConfirmation(BuildContext context, BusProvider busProvider) {
    // Show the animated confirmation overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: AlertConfirmationAnimation(
          stopName: busProvider.selectedStop ?? 'Unknown Stop',
          onAnimationComplete: () {
            Navigator.of(
              context,
            ).pop(); // Close the dialog after animation completes

            // Show a simple snackbar after the animation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Alert sent for stop: ${busProvider.selectedStop}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmExitBus(BuildContext context, BusProvider busProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Bus'),
        content: const Text('Are you sure you want to exit this bus?'),
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
              busProvider.exitBus();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have exited the bus'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
  }
}
