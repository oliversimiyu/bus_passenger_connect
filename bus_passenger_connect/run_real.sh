#!/bin/bash

# Navigate to the Flutter app directory
cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect

# Ensure http package is installed
echo "Installing http package..."
flutter pub add http

# Run the app with the real backend on Chrome
echo "Running the app with real backend on Chrome..."
flutter run -d chrome -t lib/main_real.dart
