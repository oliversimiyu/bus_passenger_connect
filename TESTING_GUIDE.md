#!/bin/bash

echo "=== Bus Passenger Connect - Complete Testing Guide ==="
echo
echo "🔧 SETUP REQUIREMENTS:"
echo "1. Backend running on this computer"
echo "2. Phone and computer on same WiFi network"
echo "3. Phone has USB debugging enabled (for USB method)"
echo
echo "📱 YOUR NETWORK INFO:"
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "   Computer IP: $LOCAL_IP"
echo "   Backend URL: http://$LOCAL_IP:5000"
echo
echo "🧪 PRE-TESTING VERIFICATION:"
echo "1. Test backend from phone browser:"
echo "   Open: http://$LOCAL_IP:5000/api/routes"
echo "   Expected: JSON with bus routes data"
echo
echo "2. Check Flutter devices:"
flutter devices
echo
echo "🚀 TESTING OPTIONS:"
echo
echo "A) USB DEBUGGING METHOD:"
echo "   1. Connect phone via USB"
echo "   2. Enable Developer Options → USB Debugging"
echo "   3. Run: flutter run --target=lib/main_real.dart"
echo
echo "B) APK INSTALLATION METHOD:"
echo "   1. Build APK: flutter build apk --target=lib/main_real.dart --release"
echo "   2. Transfer APK to phone"
echo "   3. Install and test"
echo
echo "C) WIRELESS DEBUGGING (Android 11+):"
echo "   1. Enable Developer Options → Wireless Debugging"
echo "   2. Pair device with computer"
echo "   3. Run: flutter run --target=lib/main_real.dart"
echo
echo "✅ FEATURES TO TEST ON PHONE:"
echo "□ App launches successfully"
echo "□ Sign in/register functionality"
echo "□ Map displays correctly"
echo "□ Bus routes load from backend (check Routes tab)"
echo "□ Nearby routes work"
echo "□ Location services work (if permissions granted)"
echo "□ QR code scanner works"
echo "□ Real-time updates work"
echo
echo "🐛 TROUBLESHOOTING:"
echo "- If API calls fail: Check phone can access http://$LOCAL_IP:5000"
echo "- If location doesn't work: Grant location permissions"
echo "- If maps don't load: Google Maps API key may need configuration"
echo "- If app crashes: Check Flutter console for errors"
