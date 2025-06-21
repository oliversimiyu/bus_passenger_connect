#!/bin/bash

# Build APK for Bus Passenger Connect App with Google Maps
echo "🚌 Building Bus Passenger Connect APK with Google Maps..."

cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect

echo "📱 Checking Flutter installation..."
flutter --version

echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting Flutter packages..."
flutter pub get

echo "🔍 Running code analysis..."
flutter analyze --no-fatal-warnings

echo "🔨 Building debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "📍 APK location: build/app/outputs/flutter-apk/app-debug.apk"
    
    # Copy APK to workspace root for easy access
    cp build/app/outputs/flutter-apk/app-debug.apk ../bus-passenger-connect.apk
    echo "📋 APK copied to: /home/codename/CascadeProjects/bus-passenger-connect/bus-passenger-connect.apk"
    
    # Show APK info
    echo "📊 APK Information:"
    ls -lh ../bus-passenger-connect.apk
    
    echo ""
    echo "🧪 Testing Instructions:"
    echo "1. Install APK: adb install bus-passenger-connect.apk"
    echo "2. Test map loading in Kenya"
    echo "3. Verify location permissions"
    echo "4. Check route visualization"
    echo ""
    echo "🗺️ The app should now show maps centered on Nairobi, Kenya!"
else
    echo "❌ Build failed. Check the errors above."
    exit 1
fi
