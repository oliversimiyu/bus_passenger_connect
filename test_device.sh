#!/bin/bash

echo "=== Bus Passenger Connect - Device Testing Script ==="
echo

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "📱 Your computer's IP address: $LOCAL_IP"
echo "🔧 Make sure your phone is connected to the same WiFi network"
echo

# Check if backend is running
echo "🔍 Checking if backend is running..."
if curl -s http://localhost:5000/ > /dev/null; then
    echo "✅ Backend is running on localhost:5000"
else
    echo "❌ Backend is not running. Please start it first:"
    echo "   cd backend && npm start"
    exit 1
fi

# Check connected devices
echo
echo "📱 Connected devices:"
flutter devices

echo
echo "🚀 Ready to test! Choose an option:"
echo "1. Run on connected device: flutter run --target=lib/main_real.dart"
echo "2. Build APK: flutter build apk --target=lib/main_real.dart"
echo "3. Test API from phone: curl http://$LOCAL_IP:5000/api/routes"
echo
echo "📋 Testing checklist:"
echo "□ Phone connected to same WiFi network"
echo "□ USB debugging enabled (if using USB)"
echo "□ Backend running on http://localhost:5000"
echo "□ MongoDB running"
echo "□ Flutter device detected"
