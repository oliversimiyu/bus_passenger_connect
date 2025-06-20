# Bus Passenger Connect

A Flutter mobile application for bus passengers that allows them to alert drivers when they want to alight, with QR code scanning functionality for bus entry.

## Features

- Enhanced user authentication:
  - Email and password authentication
  - Biometric authentication (fingerprint/face ID)
  - Password reset functionality
  - Token-based authentication with auto-refresh
  - Account settings management
- User profile management and session persistence
- Animated splash screen with app branding
- QR code scanning to board buses
- View bus information including route, driver details, and stops
- Search functionality to quickly find your stop
- Select a stop and alert the driver when you want to alight
- Beautiful animated confirmation when alerting the driver
- Persistent state to remember which bus you are on
- Modern and intuitive user interface
- Dark mode support through system settings

## Getting Started

### Prerequisites

- Flutter SDK (installed in ~/development/flutter)
- Android Studio or Xcode for running on devices/emulators
- A physical device is recommended for testing QR code scanning

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application on a connected device

## Usage

1. **Account Creation and Authentication**:
   - First-time users need to create an account using the Sign Up screen
   - Enter your name, email, and password to create an account
   - Returning users can sign in with their email and password
   - Users can enable biometric authentication for faster login (if device supports it)
   - Forgot password option allows users to reset their password with a verification code

2. **Boarding a Bus**:
   - After signing in, tap on "Scan QR Code"
   - Scan the QR code displayed on the bus
   - You will be boarded onto the bus

3. **Finding Your Stop**:
   - Browse the stops list or use the search icon to search for your stop
   - Select your desired stop from the list

4. **Alerting for a Stop**:
   - After selecting a stop, tap "Alert driver" to notify the driver
   - An animation will confirm your alert was sent
   - The alert can be canceled if needed

5. **Managing Your Profile**:
   - Tap the profile icon in the top right to access your profile
   - View and update account information in Account Settings
   - Enable or disable biometric authentication
   - Access travel history and favorite routes
   - Sign out when finished using the app

6. **Exiting the Bus**:
   - Tap "Exit Bus" when you've reached your destination
   - Confirm to exit the bus

## Testing

For testing purposes, you can generate a test QR code by tapping the "Generate Test QR Code" button on the home screen.

## Packages Used

- `provider`: For state management
- `shared_preferences`: For local storage of user data and bus information
- `mobile_scanner`: For QR code scanning capability
- `qr_flutter`: For generating QR codes for testing
- `local_auth`: For biometric authentication (fingerprint/face ID)
- `flutter_secure_storage`: For secure storage of tokens and sensitive data
- `email_validator`: For email validation

## Authentication System

The app uses a simulated authentication system that stores user credentials locally. In a production environment, this would be replaced with a secure backend authentication service like Firebase Authentication or a custom server implementation.

Features of the authentication system:
- User registration with email/password validation
- Login with email/password
- Biometric authentication (fingerprint/face ID)
- Password reset with verification code
- Token-based authentication with automatic refresh
- Session persistence using secure storage
- User profile management with editable fields
- Secure sign-out with proper token invalidation

## Additional Resources

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
