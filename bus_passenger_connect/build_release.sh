#!/bin/bash
# Build script for Bus Passenger Connect app

echo "Building Bus Passenger Connect APK..."

cd "$(dirname "$0")"

# Clean any previous build artifacts
echo "Cleaning previous builds..."
flutter clean
flutter pub get

# Build the release APK with the correct main file
echo "Building release APK..."
flutter build apk --release --target=lib/main_real.dart

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Show APK size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "APK size: $APK_SIZE"
    
    # Copy to root directory for easy access
    cp build/app/outputs/flutter-apk/app-release.apk ../bus-passenger-connect.apk
    echo "APK copied to ../bus-passenger-connect.apk"
else
    echo "❌ Build failed!"
    exit 1
fi
