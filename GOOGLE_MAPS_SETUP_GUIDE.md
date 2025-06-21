# Google Maps API Setup Guide

## Overview
The Bus Passenger Connect app requires a valid Google Maps API key to display maps properly. This guide will help you set up the API key correctly.

## Steps to Get Google Maps API Key

### 1. Go to Google Cloud Console
Visit: https://console.cloud.google.com/

### 2. Create or Select a Project
- Click on the project dropdown at the top
- Either select an existing project or create a new one
- Name it something like "Bus Passenger Connect"

### 3. Enable Required APIs
Navigate to **APIs & Services > Library** and enable:
- Maps SDK for Android
- Maps SDK for iOS (if building for iOS)
- Maps JavaScript API (if using web version)
- Directions API (for route planning)
- Places API (optional, for location search)

### 4. Create API Key
1. Go to **APIs & Services > Credentials**
2. Click **+ CREATE CREDENTIALS**
3. Select **API Key**
4. Copy the generated API key

### 5. Restrict the API Key (Important for Security)
1. Click on the created API key to edit it
2. Under **Application restrictions**, select **Android apps**
3. Add your app's package name: `com.cascadeprojects.bus_passenger_connect`
4. Add your app's SHA-1 certificate fingerprint (get this from your keystore)
5. Under **API restrictions**, select **Restrict key** and choose only the APIs you enabled

### 6. Update the App Configuration

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key in these files:

#### Android
File: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

#### iOS
File: `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

#### Web
File: `web/index.html`
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY_HERE"></script>
```

#### Flutter Configuration
File: `lib/config/app_config.dart`
```dart
static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

## Testing the Setup

### 1. Test API Key Validity
Visit this URL in your browser (replace with your key):
```
https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=geometry
```

You should see JavaScript code, not an error message.

### 2. Build and Test the App
```bash
# Clean the project
flutter clean
flutter pub get

# Build for Android
flutter build apk --debug

# Install on device
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 3. Test Map Loading
1. Open the app
2. Navigate to the map screen
3. You should see actual map tiles, not blank/gray areas
4. The map should center on Nairobi, Kenya

## Troubleshooting

### Maps Show Blank/Gray Areas
- Check that your API key is valid
- Ensure the Maps SDK is enabled in Google Cloud Console
- Verify the API key restrictions allow your app

### "This page can't load Google Maps correctly" Error
- The API key may be restricted incorrectly
- Check that the API is enabled for your project
- Verify billing is set up (Google requires a billing account)

### Network Errors
- Ensure the device has internet connectivity
- Check if the backend server is running (for route data)
- Verify the API base URL in `app_config.dart`

## Cost Considerations

Google Maps API usage has costs after the free tier:
- Maps SDK: $7.00 per 1,000 loads
- Directions API: $5.00 per 1,000 requests
- Free tier: $200 credit per month

For development/testing, the free tier should be sufficient.

## Security Best Practices

1. **Restrict API Keys**: Always restrict keys to specific apps/domains
2. **Monitor Usage**: Set up billing alerts in Google Cloud Console
3. **Rotate Keys**: Periodically generate new API keys
4. **Environment Variables**: In production, consider using environment variables instead of hardcoded keys

## Backend Integration

The app connects to a backend server for route data:
- Default URL: `http://192.168.100.129:5000`
- Ensure the backend is running: `cd backend && npm start`
- Test backend: `curl http://192.168.100.129:5000/api/routes`

## Kenya-Specific Configuration

The app is configured for Kenya with:
- Default location: Nairobi (-1.2921, 36.8219)
- Kenya route data in the backend
- Kenyan landmarks and bus stops

## Support

If you encounter issues:
1. Check the Flutter debug console for error messages
2. Verify all configuration files have the correct API key
3. Test the API key independently using the browser test above
4. Ensure Google Cloud billing is set up if you exceed free tier limits
