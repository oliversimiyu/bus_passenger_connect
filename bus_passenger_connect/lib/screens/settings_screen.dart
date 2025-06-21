import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_menu_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  double _mapZoomLevel = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings Section
            _buildSectionHeader('General Settings'),

            // Notifications Setting
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text(
                'Receive updates about your trips and offers',
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                // Save the setting
                _saveSetting('notifications', value);
              },
              secondary: const Icon(Icons.notifications_outlined),
            ),

            const Divider(),

            // Location Tracking Setting
            SwitchListTile(
              title: const Text('Location Tracking'),
              subtitle: const Text(
                'Allow the app to track your location during transit',
              ),
              value: _locationTrackingEnabled,
              onChanged: (value) {
                setState(() {
                  _locationTrackingEnabled = value;
                });
                // Save the setting
                _saveSetting('locationTracking', value);
              },
              secondary: const Icon(Icons.location_on_outlined),
            ),

            const Divider(),

            // Dark Mode Setting
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme for the app'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                // Save the setting
                _saveSetting('darkMode', value);
              },
              secondary: const Icon(Icons.dark_mode_outlined),
            ),

            const Divider(),

            // Language Setting
            ListTile(
              title: const Text('Language'),
              subtitle: Text(_selectedLanguage),
              leading: const Icon(Icons.language_outlined),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLanguageSelectionDialog();
              },
            ),

            const Divider(),

            // Map Settings Section
            _buildSectionHeader('Map Settings'),

            // Map Zoom Level
            ListTile(
              title: const Text('Default Map Zoom Level'),
              subtitle: Text(_mapZoomLevel.toStringAsFixed(1)),
              leading: const Icon(Icons.zoom_in_outlined),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _mapZoomLevel,
                  min: 10.0,
                  max: 20.0,
                  divisions: 20,
                  label: _mapZoomLevel.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _mapZoomLevel = value;
                    });
                  },
                  onChangeEnd: (value) {
                    // Save the setting
                    _saveSetting('mapZoomLevel', value);
                  },
                ),
              ),
            ),

            const Divider(),

            // Account Settings Section
            _buildSectionHeader('Account Settings'),

            ProfileMenuItem(
              icon: Icons.password_outlined,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {
                // Navigate to change password screen
                // TODO: Implement change password functionality
              },
            ),

            const Divider(),

            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              onTap: () {
                _showLogoutConfirmDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Show language selection dialog
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),
              _buildLanguageOption('Spanish'),
              _buildLanguageOption('French'),
              _buildLanguageOption('German'),
              _buildLanguageOption('Chinese'),
            ],
          ),
        );
      },
    );
  }

  // Build language option
  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        // Save the setting
        _saveSetting('language', language);
        Navigator.pop(context);
      },
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }

  // Save setting to preferences
  void _saveSetting(String key, dynamic value) {
    // TODO: Implement saving settings to SharedPreferences
    if (kDebugMode) {
      print('Saving setting: $key = $value');
    }
  }
}
