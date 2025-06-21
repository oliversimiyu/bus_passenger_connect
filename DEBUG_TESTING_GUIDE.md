# Debug Testing Guide for Bus Passenger Connect

## Current Status
The Bus Passenger Connect app has been enhanced with comprehensive debug logging to help troubleshoot map loading issues on physical devices.

## What's New in This Build
✅ **Debug Logging System**: Comprehensive logging throughout the app lifecycle  
✅ **Debug Screen**: In-app debug log viewer with copy/share functionality  
✅ **Network Testing**: Automatic API connectivity testing and logging  
✅ **Platform Detection**: Automatic detection and logging of device platform  
✅ **Location Debugging**: Detailed location service debugging  
✅ **Map Initialization Tracking**: Step-by-step map loading process logging  

## How to Test

### Step 1: Install the Debug APK
```bash
# Install the APK on your device
adb install bus_passenger_connect_debug.apk
```

### Step 2: Launch and Navigate to Map
1. Open the Bus Passenger Connect app
2. Navigate to the Map screen
3. Look for the red debug button (bug icon) in the bottom right corner

### Step 3: Access Debug Logs
1. Tap the red debug button (🐛) - **only visible in debug mode**
2. This opens the Debug Screen with detailed logs
3. Use the action buttons:
   - **Refresh**: Reload latest logs
   - **Copy All**: Copy logs to clipboard for sharing
   - **Clear**: Clear current logs

### Step 4: Collect Debug Information

#### If Map Loads Successfully:
- Take a screenshot of the working map
- Copy the debug logs and save them
- Note what works correctly

#### If Map Doesn't Load:
- Take a screenshot of the blank/broken map
- Copy the debug logs immediately
- Look for error messages in the logs
- Note the exact behavior (blank white, loading spinner, etc.)

## Key Debug Information to Look For

### Location Services
```
[LOCATION] Permission granted: true/false
[LOCATION] Service enabled: true/false  
[LOCATION] Current location: lat, lng
```

### Network Connectivity
```
[NETWORK] Testing connection to: API_URL
[NETWORK] Connected: true/false
[NETWORK] Response: API data or error
```

### Map Initialization
```
[MapProvider] MapProvider constructor called
[MapProvider] Starting initialization...
[MapProvider] Running on Android platform
[MapProvider] API test successful - received X routes
[MapProvider] Location obtained: lat, lng
[MapProvider] Initialization completed successfully
```

### Common Error Patterns
Look for these error indicators:
- **API connectivity failed**: Network/server issues
- **No location obtained**: GPS/permission problems  
- **Map controller not set**: Map rendering issues
- **Initialization failed**: General startup problems

## Sharing Debug Information

### Method 1: Copy from App
1. Open Debug Screen in app
2. Tap "Copy All" button
3. Paste into message/email

### Method 2: Extract Log File
```bash
# If the app creates log files, extract them:
adb pull /sdcard/Android/data/com.example.bus_passenger_connect/files/bus_app_debug.log
```

## Testing Checklist

### Basic Functionality
- [ ] App launches successfully
- [ ] Main screen loads
- [ ] Can navigate to Map screen
- [ ] Debug button is visible
- [ ] Debug screen opens and shows logs

### Map Testing
- [ ] Map appears (any tiles visible)
- [ ] Current location marker shows
- [ ] Can zoom/pan the map
- [ ] Route markers appear
- [ ] Can tap Routes button
- [ ] Route selection works

### Debug System
- [ ] Debug logs are generating
- [ ] Can copy logs to clipboard
- [ ] Logs contain useful information
- [ ] No app crashes during debugging

## Report Format

When reporting issues, please include:

**Device Information:**
- Device model: 
- Android version:
- App version: (check debug logs for system info)

**Issue Description:**
- What you were trying to do:
- What actually happened:
- Screenshots/screen recording:

**Debug Logs:**
```
[Paste debug logs here]
```

**Additional Notes:**
- Network type (WiFi/Mobile data):
- GPS enabled: Yes/No
- Location permissions granted: Yes/No
- Any error messages shown:

## Troubleshooting Tips

### If Debug Button Doesn't Appear
- Make sure you're using the debug build (not release)
- Check that you're on the Map screen
- Look for the red bug icon in the bottom right

### If App Crashes
- Try to access debug logs before reproducing the crash
- Note exactly which action caused the crash
- Try clearing app data and testing again

### If No Logs Appear
- Tap the "Generate test logs" floating button (if visible)
- Try navigating around the app to trigger logging
- Check if app has storage permissions

## Next Steps

Based on the debug information collected, we can:
1. **Identify root cause** of map loading issues
2. **Fix specific problems** found in logs
3. **Optimize performance** based on timing data
4. **Improve error handling** for edge cases
5. **Create targeted fixes** for specific device types

The debug system will help us quickly identify whether issues are:
- **Network related** (API connectivity)
- **Platform specific** (Android/device compatibility) 
- **Permission related** (GPS, storage, network)
- **Configuration issues** (API keys, settings)
- **Map service problems** (Google Maps integration)

This systematic approach will help us resolve the map loading issues efficiently and ensure the app works reliably on all devices.
