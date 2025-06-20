import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bus_provider.dart';
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: user.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          user.photoUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // User Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // User Email
              Text(
                user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // User Info Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        context,
                        Icons.person,
                        'Account Settings',
                        'Manage your account information',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AccountSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildProfileItem(
                        context,
                        Icons.history,
                        'Travel History',
                        'View your past trips',
                        onTap: () {
                          // TODO: Navigate to travel history screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Travel history coming soon'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildProfileItem(
                        context,
                        Icons.star,
                        'Favorite Routes',
                        'Access your frequently used routes',
                        onTap: () {
                          // TODO: Navigate to favorite routes screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Favorite routes coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings & Support Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        context,
                        Icons.settings,
                        'Settings',
                        'App preferences and notifications',
                        onTap: () {
                          // TODO: Navigate to settings screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings coming soon'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      _buildProfileItem(
                        context,
                        Icons.help,
                        'Help & Support',
                        'Get assistance with the app',
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
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              ElevatedButton.icon(
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
