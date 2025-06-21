#!/bin/bash

# Bus Passenger Connect - Debug Log Collection Script
echo "🔍 Starting debug log collection for Bus Passenger Connect..."
echo "================================================="

# Create logs directory
LOGS_DIR="/home/codename/CascadeProjects/bus-passenger-connect/logs"
mkdir -p "$LOGS_DIR"

# Get current timestamp
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Log files
FLUTTER_LOG="$LOGS_DIR/flutter_debug_$TIMESTAMP.log"
BACKEND_LOG="$LOGS_DIR/backend_debug_$TIMESTAMP.log"
SYSTEM_LOG="$LOGS_DIR/system_debug_$TIMESTAMP.log"
MAP_LOG="$LOGS_DIR/map_debug_$TIMESTAMP.log"

echo "📁 Log files will be saved to:"
echo "   Flutter: $FLUTTER_LOG"
echo "   Backend: $BACKEND_LOG"
echo "   System:  $SYSTEM_LOG"
echo "   Maps:    $MAP_LOG"
echo

# Function to log system info
log_system_info() {
    echo "=== SYSTEM INFORMATION ===" > "$SYSTEM_LOG"
    echo "Date: $(date)" >> "$SYSTEM_LOG"
    echo "OS: $(uname -a)" >> "$SYSTEM_LOG"
    echo "Network IP: $(hostname -I | awk '{print $1}')" >> "$SYSTEM_LOG"
    echo "Flutter Version:" >> "$SYSTEM_LOG"
    flutter --version >> "$SYSTEM_LOG" 2>&1
    echo "" >> "$SYSTEM_LOG"
    
    echo "=== CONNECTED DEVICES ===" >> "$SYSTEM_LOG"
    flutter devices >> "$SYSTEM_LOG" 2>&1
    echo "" >> "$SYSTEM_LOG"
    
    echo "=== BACKEND STATUS ===" >> "$SYSTEM_LOG"
    if curl -s http://localhost:5000/ > /dev/null 2>&1; then
        echo "Backend: ✅ Running" >> "$SYSTEM_LOG"
        echo "Routes API Test:" >> "$SYSTEM_LOG"
        curl -s http://localhost:5000/api/routes | head -20 >> "$SYSTEM_LOG" 2>&1
    else
        echo "Backend: ❌ Not running" >> "$SYSTEM_LOG"
    fi
    echo "" >> "$SYSTEM_LOG"
}

# Function to start Flutter logging
start_flutter_logging() {
    echo "🚀 Starting Flutter app with detailed logging..."
    echo "=== FLUTTER DEBUG LOG - Started at $(date) ===" > "$FLUTTER_LOG"
    
    cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect
    
    # Start Flutter with verbose logging
    flutter run --target=lib/main_real.dart --verbose --device-timeout=60 >> "$FLUTTER_LOG" 2>&1 &
    FLUTTER_PID=$!
    
    echo "Flutter app started with PID: $FLUTTER_PID"
    echo "Logs are being written to: $FLUTTER_LOG"
    
    return $FLUTTER_PID
}

# Function to monitor backend
monitor_backend() {
    echo "📊 Monitoring backend logs..."
    echo "=== BACKEND DEBUG LOG - Started at $(date) ===" > "$BACKEND_LOG"
    
    # Monitor backend logs if it's running
    if pgrep -f "node.*index.js" > /dev/null; then
        echo "Backend is running, monitoring logs..." >> "$BACKEND_LOG"
        # Tail backend logs (assuming it logs to console)
        tail -f /home/codename/CascadeProjects/bus-passenger-connect/backend/debug.log >> "$BACKEND_LOG" 2>&1 &
    else
        echo "Backend not running. Please start it manually." >> "$BACKEND_LOG"
    fi
}

# Function to create map-specific debug log
create_map_debug_log() {
    cat > "$MAP_LOG" << 'EOF'
=== MAP DEBUG LOG ===
Date: $(date)

MAP LOADING TROUBLESHOOTING CHECKLIST:

1. GOOGLE MAPS API KEY:
   - Key: AIzaSyBt6csGnCnYsHGXwQE-QFGOuwhfvOWQw-Q
   - Status: Test key (may have limitations)
   - Required: Enable Maps SDK for Android in Google Cloud Console

2. LOCATION PERMISSIONS:
   - Check if app requests location permission
   - Check if permission is granted in phone settings
   - Required for: GPS location, map centering

3. NETWORK CONNECTIVITY:
   - Backend URL: http://192.168.100.129:5000
   - Test from phone browser: http://192.168.100.129:5000/api/routes
   - WiFi: Phone and computer must be on same network

4. ANDROID MANIFEST PERMISSIONS:
   - ACCESS_FINE_LOCATION: ✅
   - ACCESS_COARSE_LOCATION: ✅
   - INTERNET: ✅
   - Google Maps API Key: ✅

5. FLUTTER MAP CONFIGURATION:
   - google_maps_flutter plugin: Installed
   - Initial camera position: Nairobi (-1.2921, 36.8219)
   - Map type: Normal
   - Location enabled: true

COMMON MAP ISSUES AND SOLUTIONS:

❌ MAP APPEARS BLANK:
   - API key not working -> Check Google Cloud Console
   - Network issues -> Test backend connectivity
   - Location permissions -> Grant in app settings
   - Plugin issues -> Check Flutter logs

❌ LOCATION NOT DETECTED:
   - GPS disabled -> Enable location services
   - Permissions denied -> Grant location permission
   - Indoor location -> Try outdoors for better signal
   - Simulated location -> Check if using emulator

❌ ROUTES NOT LOADING:
   - Backend not accessible -> Test API from phone browser
   - Network timeout -> Check WiFi connection
   - API errors -> Check backend logs

DEBUGGING STEPS:
1. Open app and go to Map screen
2. Check if loading indicator appears
3. Check if permission dialogs appear
4. Note any error messages
5. Check console logs for errors
6. Test backend API from phone browser

FLUTTER CONSOLE COMMANDS WHILE DEBUGGING:
- 'r' to hot reload
- 'R' to hot restart
- 'o' to toggle platform (Android/iOS)
- 'q' to quit

EXPECTED LOG MESSAGES:
✅ "MapProviderReal: Starting initialization..."
✅ "MapScreen: Map created successfully"
✅ "Current location available: LatLng(...)"
✅ "Fetched X routes"

❌ ERROR INDICATORS:
❌ "Error initializing MapProvider"
❌ "Failed to get location"
❌ "Map creation failed"
❌ "API connection error"

EOF
}

# Main execution
echo "🔧 Collecting system information..."
log_system_info

echo "📝 Creating map debug guide..."
create_map_debug_log

echo "🎯 Debug environment ready!"
echo
echo "USAGE:"
echo "1. Run Flutter app: ./start_debug_session.sh"
echo "2. Install APK on phone and test"
echo "3. Check logs in real-time: tail -f $LOGS_DIR/flutter_debug_*.log"
echo "4. Review all logs after testing"
echo
echo "REAL-TIME MONITORING:"
echo "   tail -f $FLUTTER_LOG"
echo "   tail -f $MAP_LOG"
echo
echo "Log files created in: $LOGS_DIR"
