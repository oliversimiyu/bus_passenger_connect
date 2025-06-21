#!/bin/bash

echo "🚀 Bus Passenger Connect - APK Installation Helper"
echo "================================================="
echo

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APK_PATH="/home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect/build/app/outputs/flutter-apk/app-release.apk"

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ APK not found at: $APK_PATH${NC}"
    echo "Building APK first..."
    cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect
    flutter build apk --target=lib/main_real.dart --release
    
    if [ ! -f "$APK_PATH" ]; then
        echo -e "${RED}❌ APK build failed. Please check the build output.${NC}"
        exit 1
    fi
fi

# Get APK info
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
APK_DATE=$(stat -c %y "$APK_PATH" | cut -d' ' -f1,2 | cut -d'.' -f1)

echo -e "${GREEN}✅ APK Found:${NC}"
echo "   📍 Location: $APK_PATH"
echo "   📏 Size: $APK_SIZE"
echo "   📅 Built: $APK_DATE"
echo

# Check if device is connected
echo "🔍 Checking for connected devices..."
DEVICES=$(flutter devices | grep -E "(android|iOS)")

if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}⚠️  No devices detected${NC}"
    echo
    echo "📱 Manual Installation Options:"
    echo
    echo "1️⃣  USB Method:"
    echo "   • Connect phone via USB"
    echo "   • Enable USB Debugging"
    echo "   • Run: flutter install --target=lib/main_real.dart"
    echo
    echo "2️⃣  File Transfer Method:"
    echo "   • Copy APK to phone: $APK_PATH"
    echo "   • Enable 'Install from Unknown Sources'"
    echo "   • Tap APK file to install"
    echo
    echo "3️⃣  Cloud Transfer:"
    echo "   • Upload APK to Google Drive/Dropbox"
    echo "   • Download on phone and install"
    echo
else
    echo -e "${GREEN}✅ Connected devices found:${NC}"
    echo "$DEVICES"
    echo
    echo "🚀 Ready to install! Choose an option:"
    echo "1) Install directly to connected device"
    echo "2) Copy APK path for manual transfer"
    echo "3) Show installation instructions"
    echo
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo "📱 Installing APK to connected device..."
            cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect
            flutter install --target=lib/main_real.dart
            ;;
        2)
            echo -e "${YELLOW}📋 APK Path:${NC}"
            echo "$APK_PATH"
            echo
            echo "Copy this file to your phone and install manually."
            ;;
        3)
            echo -e "${YELLOW}📖 Installation Instructions:${NC}"
            echo "1. Transfer APK to phone"
            echo "2. Enable 'Install from Unknown Sources' in phone settings"
            echo "3. Tap the APK file to install"
            echo "4. Replace existing app if prompted"
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            ;;
    esac
fi

echo
echo "🧪 After installation, please test:"
echo "   ✅ Map loads and shows your location"
echo "   ✅ Routes tab loads bus routes"
echo "   ✅ Location button centers map"
echo "   ✅ Backend connectivity works"
echo
echo -e "${GREEN}📚 Full testing guide: APK_TESTING_GUIDE.md${NC}"
