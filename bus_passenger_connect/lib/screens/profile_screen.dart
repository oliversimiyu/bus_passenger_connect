import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_menu_item.dart';
import 'travel_history_screen.dart';
import 'favorite_routes_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    // If the user is authenticated but profile provider hasn't synced yet,
    // sync the profile provider with authenticated user data
    if (user != null &&
        (profileProvider.userProfile == null ||
            profileProvider.userProfile!.id != user.id)) {
      // Schedule the sync for the next frame to avoid triggering during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileProvider.syncWithAuthUser(user);
      });
    }

    // Use authenticated user data if available
    final userProfile =
        profileProvider.userProfile ??
        UserProfile(
          id: user?.id ?? 'guest',
          name: user?.name ?? 'Guest User',
          email: user?.email ?? 'guest@example.com',
          profileImageUrl: user?.photoUrl,
          favoriteRouteIds: const [],
          favoriteRoutes: const [],
          travelHistory: const [],
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child:
                        userProfile.profileImageUrl != null &&
                            userProfile.profileImageUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              userProfile.profileImageUrl!,
                            ),
                            onBackgroundImageError: (exception, stackTrace) {
                              if (kDebugMode) {
                                print(
                                  'Error loading profile image: $exception',
                                );
                              }
                              // Return a fallback on error
                              return;
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              userProfile.name.isNotEmpty
                                  ? userProfile.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    userProfile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    userProfile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Profile Menu Items
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Account Settings
                  ProfileMenuItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Account Settings',
                    subtitle: 'Manage your account information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Travel History
                  ProfileMenuItem(
                    icon: Icons.history,
                    title: 'Travel History',
                    subtitle: 'View your past trips',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TravelHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Favorite Routes
                  ProfileMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Favorite Routes',
                    subtitle: 'Manage your favorite routes',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoriteRoutesScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Help & Support
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance and answers to your questions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Logout
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () {
                      _showLogoutDialog(context, authProvider);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text("Signing out..."),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Wait for signOut to complete with timeout protection
              try {
                await authProvider.signOut().timeout(
                  const Duration(seconds: 5),
                  onTimeout: () {
                    if (kDebugMode) {
                      print("Sign out timed out, but continuing app flow");
                    }
                    // Force state to be cleared anyway
                    authProvider.forceSignOut();
                  },
                );
              } catch (e) {
                if (kDebugMode) {
                  print("Error during sign out: $e");
                }
              }

              // Close the loading dialog and return to home
              if (context.mounted) {
                Navigator.of(context).pop(); // Close the loading dialog

                // Small delay to ensure navigation works smoothly
                await Future.delayed(const Duration(milliseconds: 100));

                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}
