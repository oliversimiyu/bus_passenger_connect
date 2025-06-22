import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bus_provider.dart';
import '../widgets/profile_menu_item.dart';
import 'sign_in_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      // Fallback if user is not authenticated
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: user.photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        user.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person, size: 50, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // User Email
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),

            // Menu Items Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Account Settings',
                    subtitle: 'Manage your account information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.history,
                    title: 'Travel History',
                    subtitle: 'View your past trips',
                    onTap: () {
                      // TODO: Navigate to travel history screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Travel history coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.star_outline,
                    title: 'Favorite Routes',
                    subtitle: 'Access your frequently used routes',
                    onTap: () {
                      // TODO: Navigate to favorite routes screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorite routes coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences and notifications',
                    onTap: () {
                      // TODO: Navigate to settings screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance with the app',
                    onTap: () {
                      // TODO: Navigate to help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton.icon(
                onPressed: () => _confirmSignOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();

              // Sign out the user
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              // Clear bus state
              final busProvider = Provider.of<BusProvider>(
                context,
                listen: false,
              );
              await busProvider.exitBus();

              // Sign out and navigate to sign in
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }
}
