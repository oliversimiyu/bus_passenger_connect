import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with support illustration
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.support_agent,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Contact Support Section
            _buildSectionTitle(context, 'Contact Support'),
            const SizedBox(height: 8),

            _buildContactTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@busconnect.com',
              onTap: () => _launchEmail('support@busconnect.com'),
            ),

            _buildContactTile(
              context,
              icon: Icons.phone_outlined,
              title: 'Call Support',
              subtitle: '+1 (555) 123-4567',
              onTap: () => _launchPhone('+15551234567'),
            ),

            _buildContactTile(
              context,
              icon: Icons.chat_outlined,
              title: 'Live Chat',
              subtitle: 'Available 9 AM - 5 PM',
              onTap: () => _showLiveChatDialog(context),
            ),

            const Divider(height: 32),

            // FAQ Section
            _buildSectionTitle(context, 'Frequently Asked Questions'),
            const SizedBox(height: 8),

            _buildExpandableFaq(
              context,
              question: 'How do I track my bus location?',
              answer:
                  'To track your bus, open the map screen and select your route. The app will show you the real-time location of your bus and estimated arrival time.',
            ),

            _buildExpandableFaq(
              context,
              question: 'How do I purchase tickets?',
              answer:
                  'You can purchase tickets by going to the Tickets tab and selecting your desired route. Follow the payment process to complete your purchase.',
            ),

            _buildExpandableFaq(
              context,
              question: 'What do I do if I lost an item on the bus?',
              answer:
                  'For lost items, please contact our support team with details about your trip and the lost item. We\'ll help coordinate with the bus operator to locate your item.',
            ),

            _buildExpandableFaq(
              context,
              question: 'How do I report a problem with the app?',
              answer:
                  'To report an app issue, go to Settings > Report a Problem, or contact our support team directly via email or phone.',
            ),

            const Divider(height: 32),

            // Video Tutorials Section
            _buildSectionTitle(context, 'Video Tutorials'),
            const SizedBox(height: 8),

            _buildTutorialTile(
              context,
              title: 'Getting Started',
              duration: '3:45',
              onTap: () => _showVideoTutorial(context, 'Getting Started'),
            ),

            _buildTutorialTile(
              context,
              title: 'Using the Map',
              duration: '2:30',
              onTap: () => _showVideoTutorial(context, 'Using the Map'),
            ),

            _buildTutorialTile(
              context,
              title: 'Managing Your Profile',
              duration: '1:55',
              onTap: () => _showVideoTutorial(context, 'Managing Your Profile'),
            ),

            const Divider(height: 32),

            // App Information
            _buildSectionTitle(context, 'About the App'),
            const SizedBox(height: 8),

            ListTile(
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),

            ListTile(
              title: const Text('Terms of Service'),
              leading: const Icon(Icons.description_outlined),
              onTap: () => _showTermsOfService(context),
            ),

            ListTile(
              title: const Text('Privacy Policy'),
              leading: const Icon(Icons.privacy_tip_outlined),
              onTap: () => _showPrivacyPolicy(context),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Build section title widget
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Build contact tile widget
  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Build expandable FAQ widget
  Widget _buildExpandableFaq(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text(answer)),
        ],
      ),
    );
  }

  // Build tutorial tile widget
  Widget _buildTutorialTile(
    BuildContext context, {
    required String title,
    required String duration,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline),
        title: Text(title),
        subtitle: Text('Duration: $duration'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Launch email app
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello, I need help with:',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (kDebugMode) {
        print('Could not launch $emailUri');
      }
    }
  }

  // Launch phone app
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (kDebugMode) {
        print('Could not launch $phoneUri');
      }
    }
  }

  // Show live chat dialog
  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'This feature would connect to a live support agent. In a real app, this would integrate with a chat service API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  // Show video tutorial dialog
  void _showVideoTutorial(BuildContext context, String tutorialName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$tutorialName Tutorial'),
        content: const Text(
          'This would play a video tutorial. In a real app, this would open a video player or a web view with the tutorial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  // Show terms of service
  void _showTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LegalDocumentScreen(
          title: 'Terms of Service',
          content: _getDummyTermsOfService(),
        ),
      ),
    );
  }

  // Show privacy policy
  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _LegalDocumentScreen(
          title: 'Privacy Policy',
          content: _getDummyPrivacyPolicy(),
        ),
      ),
    );
  }

  // Get dummy terms of service text
  String _getDummyTermsOfService() {
    return '''
# Terms of Service

Last Updated: ${DateTime.now().toString().substring(0, 10)}

## 1. Acceptance of Terms

By accessing and using the Bus Passenger Connect application, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.

## 2. Description of Service

Bus Passenger Connect is a mobile application that provides bus tracking, route information, and related services to help passengers navigate public transportation.

## 3. User Accounts

To use certain features of the application, you may be required to create an account. You are responsible for maintaining the confidentiality of your account information.

## 4. User Conduct

You agree not to use the application for any unlawful purpose or in any way that could damage, disable, or impair the service.

## 5. Intellectual Property

All content, features, and functionality of the application are owned by Bus Passenger Connect and are protected by copyright, trademark, and other intellectual property laws.

## 6. Limitation of Liability

The application is provided "as is" without warranties of any kind, either express or implied.

## 7. Changes to Terms

We reserve the right to modify these terms at any time. Your continued use of the application after such changes constitutes your acceptance of the new terms.
''';
  }

  // Get dummy privacy policy text
  String _getDummyPrivacyPolicy() {
    return '''
# Privacy Policy

Last Updated: ${DateTime.now().toString().substring(0, 10)}

## 1. Information We Collect

We collect information that you provide directly to us, such as when you create an account, use our services, or contact us for support.

## 2. Location Information

With your consent, we collect precise location information from your device when the app is running. This helps us provide you with accurate bus tracking and arrival estimates.

## 3. How We Use Your Information

We use the information we collect to provide, maintain, and improve our services, including:
- Displaying real-time bus locations and routes
- Providing personalized route recommendations
- Sending notifications about bus arrivals and service changes

## 4. Information Sharing

We do not share your personal information with third parties except as described in this privacy policy.

## 5. Data Security

We take reasonable measures to help protect your personal information from loss, theft, misuse, and unauthorized access.

## 6. Your Choices

You can control the app's access to your location through your device settings. You can also delete your account at any time through the app's settings.

## 7. Changes to This Policy

We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.
''';
  }
}

// Legal document screen (for Terms and Privacy Policy)
class _LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String content;

  const _LegalDocumentScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(content, style: const TextStyle(fontSize: 16))],
        ),
      ),
    );
  }
}
