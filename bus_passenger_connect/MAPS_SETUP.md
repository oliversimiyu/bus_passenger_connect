# Google Maps Integration Setup

To properly set up the Google Maps functionality in the Bus Passenger Connect app, follow these steps:

## Step 1: Get a Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Google Maps Android API
   - Google Maps iOS SDK
   - Directions API
   - Places API
4. Create credentials to get an API key
5. Restrict the API key to your application by adding your app's package name and SHA-1 fingerprint

## Step 2: Add the API Key to Your Project

### For Android:
1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace the placeholder API key in the meta-data section:
   ```xml
   <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_ACTUAL_API_KEY_HERE" />
   ```

### For iOS:
1. Open `ios/Runner/AppDelegate.swift`
2. Replace the placeholder API key:
   ```swift
   GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
   ```

### For the App Config:
1. Open `lib/config/app_config.dart`
2. Replace the empty string with your actual API key:
   ```dart
   static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
   ```

## Step 3: Test the Integration

1. Build and run the app
2. Navigate to the Maps screen
3. Verify that the map loads properly and you can see the available routes

## Troubleshooting

If you encounter issues:
- Make sure your API key is correctly added to all locations
- Verify that all required APIs are enabled in the Google Cloud Console
- Check that your API key has the proper restrictions and permissions
- If running on an emulator, ensure the emulator has Google Play Services installed
