#!/bin/bash

# 🚌 Bus Passenger Connect - Google Maps Kenya APK Testing
echo "🚌 Bus Passenger Connect - Google Maps Kenya Implementation"
echo "======================================================"

APK_FILE="/home/codename/CascadeProjects/bus-passenger-connect/bus-passenger-connect-maps.apk"

echo ""
echo "📱 APK Information:"
echo "File: bus-passenger-connect-maps.apk"
echo "Size: $(ls -lh $APK_FILE | awk '{print $5}')"
echo "SHA1: $(sha1sum $APK_FILE | awk '{print $1}')"
echo ""

echo "🔧 Installation Instructions:"
echo "1. Connect your Android device via USB"
echo "2. Enable USB Debugging in Developer Options"
echo "3. Run: adb install bus-passenger-connect-maps.apk"
echo ""

echo "🧪 Testing Checklist:"
echo "□ Map loads with actual tiles (not blank/gray)"
echo "□ Map centers on Nairobi, Kenya (-1.2921, 36.8219)"
echo "□ Kenya landmarks are visible"
echo "□ Location permissions work correctly"
echo "□ Route visualization displays properly"
echo "□ Error handling works gracefully"
echo ""

echo "🎯 Key Features to Test:"
echo "• Basic Map Loading (Scenario 1)"
echo "• Kenya Location Focus (Scenario 2)"
echo "• Location Permissions (Scenario 3)"
echo "• Route Visualization (Scenario 4)"
echo "• Network Conditions (Scenario 5)"
echo "• Error Handling (Scenario 6)"
echo ""

echo "📋 Quick Test Steps:"
echo "1. Open the app and sign in"
echo "2. Tap 'Track Route' or 'Transit Map'"
echo "3. Allow location permissions when prompted"
echo "4. Verify map shows Nairobi, Kenya"
echo "5. Test route selection and visualization"
echo "6. Test 'My Location' button"
echo ""

echo "🔍 Install Command:"
echo "adb install $APK_FILE"
echo ""

# Check if ADB is available
if command -v adb &> /dev/null; then
    echo "✅ ADB is available"
    
    # Check if device is connected
    if adb devices | grep -q "device$"; then
        echo "✅ Android device detected"
        echo ""
        echo "🚀 Ready to install! Run:"
        echo "adb install $APK_FILE"
    else
        echo "⚠️  No Android device connected"
        echo "Connect your device and enable USB debugging"
    fi
else
    echo "⚠️  ADB not found. Install Android SDK Platform Tools"
fi

echo ""
echo "📖 For detailed testing guide, see: COMPLETE_MAPS_TESTING_GUIDE.md"
echo "🎉 APK build completed successfully!"
