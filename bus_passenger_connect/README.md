# Bus Passenger Connect

A Flutter mobile application for bus passengers in Kenya that allows them to track bus routes in real-time, alert drivers when they want to alight, and board buses using QR code scanning. The app features backend integration for live route data and Google Maps integration specifically configured for Kenya.

## 🚌 Features

### **Real-time Bus Tracking**
- **Live route tracking** with backend-integrated map functionality
- **Google Maps integration** optimized for Kenya (Nairobi-focused)
- **Real-time location updates** with GPS tracking
- **Route visualization** showing bus paths and stops
- **Kenya-specific landmarks** and location defaults

### **User Authentication & Profile**
- **Enhanced user authentication** system:
  - Email and password authentication
  - Biometric authentication (fingerprint/face ID)
  - Password reset functionality
  - Token-based authentication with auto-refresh
  - Account settings management
- **User profile management** and session persistence
- **Travel history** and favorite routes tracking

### **Bus Boarding & Alerts**
- **QR code scanning** to board buses
- **Driver alert system** to signal when you want to alight
- **Stop search functionality** to quickly find your destination
- **Beautiful animated confirmations** for user actions
- **Persistent state** to remember which bus you are on

### **User Interface & Experience**
- **Animated splash screen** with app branding
- **Modern and intuitive** user interface
- **Dark mode support** through system settings
- **Kenya-focused experience** with local landmarks and geography

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (version 3.0 or higher)
- **Android Studio** or **Xcode** for running on devices/emulators
- **Physical Android device** recommended for testing QR code scanning and GPS functionality
- **Google Maps API Key** (see setup instructions below)
- **Backend server** running (optional for development with mock data)

### Backend Integration

This app connects to a backend server for real-time bus route data. The backend provides:
- **Real bus routes** with Kenya locations (Nairobi, Westlands, Karen, JKIA)
- **Real-time location updates** for buses
- **Route optimization** and scheduling data
- **Driver and bus management** APIs

**Backend server configuration:**
- Development server: `http://192.168.100.129:5000`
- API endpoints: `/api/routes`, `/api/buses`, `/api/location`
- Auto-detects platform (web uses localhost, mobile uses network IP)

### Google Maps Setup

1. **Get a Google Maps API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing
   - Enable these APIs:
     - Google Maps Android API
     - Google Maps iOS SDK  
     - Directions API
     - Places API
   - Create credentials to get an API key

2. **Configure the API Key:**
   - **Android**: Update `android/app/src/main/AndroidManifest.xml`
   - **iOS**: Update `ios/Runner/AppDelegate.swift` 
   - **App Config**: Update `lib/config/app_config.dart`
   - See `GOOGLE_MAPS_SETUP_GUIDE.md` for detailed instructions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bus_passenger_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API key** (see setup instructions above)

4. **Run the application**
   ```bash
   flutter run
   ```

5. **For production builds:**
   ```bash
   # Debug APK
   flutter build apk --debug
   
   # Release APK  
   flutter build apk --release
   ```

## 📱 Usage

### **Getting Started**
1. **Account Creation and Authentication**:
   - First-time users need to create an account using the Sign Up screen
   - Enter your name, email, and password to create an account
   - Returning users can sign in with their email and password
   - Users can enable biometric authentication for faster login (if device supports it)
   - Forgot password option allows users to reset their password with a verification code

### **Real-time Route Tracking**
2. **Track Bus Routes**:
   - After signing in, tap "Track Route" to access the live map
   - View real-time bus locations and routes throughout Kenya
   - Map automatically centers on Nairobi with Kenya landmarks visible
   - Select available routes to see detailed information and tracking

### **Boarding a Bus**
3. **QR Code Boarding**:
   - Tap "Scan QR Code" to board a bus
   - Scan the QR code displayed on the bus
   - You will be boarded onto the bus and can track your journey

### **Finding Your Stop**
4. **Stop Selection**:
   - Browse the stops list or use the search icon to search for your stop
   - Select your desired stop from the available options
   - View route information including distance and estimated time

### **Alerting for a Stop**
5. **Driver Alerts**:
   - After selecting a stop, tap "Alert driver" to notify the driver
   - An animation will confirm your alert was sent
   - The alert can be canceled if needed before reaching the stop

### **Profile Management**
6. **Account Features**:
   - Tap the profile icon in the top right to access your profile
   - View and update account information in Account Settings
   - Enable or disable biometric authentication
   - Access travel history and favorite routes
   - Sign out when finished using the app

### **Journey Completion**
7. **Exiting the Bus**:
   - Tap "Exit Bus" when you've reached your destination
   - Confirm to exit the bus and end journey tracking

## 🧪 Testing & Development

### **Testing QR Codes**
For testing purposes, you can generate a test QR code by tapping the "Generate Test QR Code" button on the home screen.

### **Map Testing**
The app includes Kenya-specific test data:
- **Default location**: Nairobi CBD (-1.2921, 36.8219)
- **Test routes**: Nairobi City Express, Karen-Langata Line, Eastlands Connect
- **Landmarks**: JKIA, Westlands, Karen, Nairobi CBD

## 📦 Dependencies & Packages

### **Core Dependencies**
- **`provider`**: State management for app-wide data
- **`google_maps_flutter`**: Google Maps integration for route visualization  
- **`geolocator`**: GPS location services and permissions
- **`http`**: Backend API communication

### **Authentication & Security**
- **`local_auth`**: Biometric authentication (fingerprint/face ID)
- **`flutter_secure_storage`**: Secure storage of tokens and sensitive data
- **`email_validator`**: Email validation for user registration

### **Local Storage & Persistence**
- **`shared_preferences`**: Local storage of user data and app settings
- **`sqflite`**: Local database for offline data caching

### **UI & User Experience**
- **`mobile_scanner`**: QR code scanning capability
- **`qr_flutter`**: QR code generation for testing
- **`flutter_svg`**: SVG asset support for icons and graphics

### **Backend Integration**
- **Real-time API**: Connects to backend server for live route data
- **Location tracking**: GPS integration with route optimization
- **Authentication tokens**: Secure user session management

## 🔧 Architecture & Technical Details

### **Backend Integration Architecture**
The app uses a dual-service architecture:

1. **Real API Service** (`api_service_real.dart`):
   - Connects to backend server at `http://192.168.100.129:5000`
   - Provides live Kenya bus route data
   - Handles real-time location updates
   - Used by `MapScreenReal` for production functionality

2. **Mock API Service** (`api_service.dart`):
   - Provides fallback data for development/testing
   - Simulates backend responses
   - Used for offline development

### **Map Provider Architecture**
- **`MapProviderReal`**: Backend-integrated map functionality
- **Real-time location tracking** with Kenya GPS coordinates
- **Route visualization** with Google Maps polylines
- **Marker management** for buses, stops, and landmarks

### **Authentication System**
The app uses a comprehensive authentication system with:
- **User registration** with email/password validation
- **Login with email/password** and biometric options
- **Password reset** with verification code
- **Token-based authentication** with automatic refresh
- **Session persistence** using secure storage
- **User profile management** with editable fields

*In a production environment, this integrates with the backend authentication service.*

## 🌍 Kenya-Specific Features

### **Localized for Kenya**
- **Default location**: Nairobi CBD (-1.2921, 36.8219)
- **Kenya landmarks**: JKIA Airport, Westlands, Karen, Nairobi CBD
- **Local route data**: Bus routes connecting major Kenya locations
- **GPS bounds**: Automatically keeps focus within Kenya territory

### **Real Kenya Bus Routes**
The backend provides real bus route data including:
- **Nairobi City Express**: Westlands to Nairobi CBD
- **Karen-Langata Line**: Karen to Langata and city center  
- **Eastlands Connect**: Eastlands to various city destinations
- **Real-time updates**: Live bus locations and ETA calculations

## 🔧 Configuration & Setup

### **Backend Server Configuration**
The app automatically detects the correct backend URL:
- **Web development**: `http://localhost:5000`
- **Android devices**: `http://192.168.100.129:5000`
- **iOS devices**: `http://192.168.100.129:5000`

### **Google Maps API Configuration**
1. Replace placeholder in `lib/config/app_config.dart`:
   ```dart
   static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
   ```

2. Update platform-specific configurations:
   - **Android**: `android/app/src/main/AndroidManifest.xml`
   - **iOS**: `ios/Runner/AppDelegate.swift`
   - **Web**: `web/index.html`

### **Development vs Production**
- **Development**: Uses local mock data if backend unavailable
- **Production**: Requires backend server for real-time functionality
- **Testing**: Includes comprehensive test data for Kenya routes

## 📋 Available Documentation

### **Setup & Configuration**
- **`GOOGLE_MAPS_SETUP_GUIDE.md`**: Complete Google Maps API setup
- **`BACKEND_INTEGRATION_FIX_REPORT.md`**: Technical backend integration details
- **`MAPS_FIXED_FINAL_SUMMARY.md`**: Executive summary of recent fixes

### **Testing & Development**
- **`COMPLETE_MAPS_TESTING_GUIDE.md`**: Comprehensive testing instructions
- **`APK_BUILD_SUCCESS.md`**: APK build and testing guide
- **`MAPS_TESTING_SUMMARY.md`**: Quick testing reference

## 🚨 Troubleshooting

### **Map Issues**
- **Blank/gray map**: Check internet connection and Google Maps API key
- **Wrong location**: Verify Kenya coordinates in `app_config.dart`
- **Permission errors**: Enable location permissions in device settings

### **Backend Issues**  
- **No route data**: Verify backend server is running
- **Connection errors**: Check network connectivity and API base URL
- **Authentication errors**: Verify user tokens and session state

### **Building Issues**
- **Dependency conflicts**: Run `flutter clean && flutter pub get`
- **API key errors**: Verify all API keys are properly configured
- **Platform errors**: Check Android SDK and iOS development setup

## 🔄 Recent Updates (Backend Integration)

### **Major Changes Implemented**
1. **Backend Integration**: App now connects to real backend server for live data
2. **Map Provider Updates**: Enhanced `MapProviderReal` with backend connectivity  
3. **Navigation Updates**: Main app now uses backend-integrated map screens
4. **Code Cleanup**: Removed duplicate map implementations and fixed compilation errors
5. **Google Maps Enhancement**: Improved API key management and configuration

### **Files Modified**
- `lib/screens/home_screen.dart` - Updated to use `MapScreenReal`
- `lib/widgets/map_navigation_button.dart` - Backend-integrated navigation
- `lib/providers/map_provider.dart` - Fixed duplicate method compilation error
- `lib/config/app_config.dart` - Enhanced Google Maps API configuration

### **APK Builds Available**  
- **Latest**: `bus-passenger-connect-backend-integrated.apk` (111 MB)
- **Previous**: Various builds for comparison and testing
- **Release**: Production-ready build with optimizations

## 📞 Support & Contributing

### **Getting Help**
- **Issues**: Report bugs and feature requests via GitHub issues
- **Documentation**: Check the comprehensive guides in the project root
- **Testing**: Follow the testing guides for proper verification

### **Development Environment**
- **Flutter**: Version 3.0+ recommended
- **Android Studio**: Latest stable version
- **Xcode**: For iOS development (macOS only)
- **Git**: For version control and collaboration

### **Contributing Guidelines**
1. **Fork the repository** and create a feature branch
2. **Follow Flutter best practices** and existing code style
3. **Test thoroughly** on physical devices, especially for GPS/map features
4. **Update documentation** if adding new features
5. **Submit pull requests** with clear descriptions

### **Code Structure**
```
lib/
├── screens/           # UI screens (home, map, auth, etc.)
├── providers/         # State management (map, auth, bus data)
├── services/          # API services (real and mock)
├── models/           # Data models (routes, buses, users)
├── widgets/          # Reusable UI components
├── config/           # App configuration (API keys, URLs)
└── utils/            # Helper functions and utilities
```

## 🎯 Project Status

### **Current Status: ✅ Production Ready**
- **Backend Integration**: Fully implemented and tested
- **Google Maps**: Properly configured for Kenya
- **APK Builds**: Debug and release builds available
- **Documentation**: Comprehensive setup and testing guides
- **Code Quality**: Cleaned up, no compilation errors

### **Next Steps**
1. **Production Deployment**: Deploy backend to production server
2. **Google Play Store**: Prepare for app store submission  
3. **User Testing**: Conduct extensive testing with real Kenya bus routes
4. **Performance Optimization**: Monitor and optimize for Kenya network conditions

## 📚 Additional Resources

### **Flutter Development**
- [Flutter Documentation](https://docs.flutter.dev/) - Official Flutter guides and API reference
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter) - Maps integration documentation
- [Provider State Management](https://pub.dev/packages/provider) - State management best practices

### **Google Maps APIs**
- [Google Cloud Console](https://console.cloud.google.com/) - API key management
- [Maps SDK for Android](https://developers.google.com/maps/documentation/android-sdk)
- [Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk)

### **Kenya-Specific Resources**
- **Nairobi Bus Routes**: Integration with local transit authorities
- **Kenya GPS Coordinates**: Boundary verification and landmark data
- **Local Testing**: Kenya-specific testing scenarios and use cases

---

**🚌 Bus Passenger Connect - Connecting Kenya's Commuters with Real-time Bus Tracking 🇰🇪**
