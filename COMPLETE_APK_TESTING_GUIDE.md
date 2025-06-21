# Complete APK Testing Guide with Debug System

## 🚀 SUCCESS STATUS
✅ **APK Successfully Built**: `app-release.apk` (39.5MB) with real backend integration
✅ **Backend Running**: MongoDB + Node.js API server on localhost:5000
✅ **Debug System Integrated**: In-app logging and debug screen
✅ **Network Auto-Detection**: App automatically detects correct API endpoints

---

## 📱 APK Installation & Testing

### Prerequisites
1. **Android device** with USB debugging enabled
2. **ADB installed** on development machine
3. **Backend server running** (MongoDB + Node.js)

### Quick Setup Commands

```bash
# 1. Copy APK to project root for easy access
cp /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect/build/app/outputs/flutter-apk/app-release.apk /home/codename/CascadeProjects/bus-passenger-connect/

# 2. Connect your Android device via USB and install
adb install app-release.apk

# 3. Start the backend if not running
cd /home/codename/CascadeProjects/bus-passenger-connect/backend
chmod +x start.sh
./start.sh
```

---

## 🔧 Backend Server Commands

### Start Backend
```bash
cd /home/codename/CascadeProjects/bus-passenger-connect/backend
./start.sh
```

### Test Backend APIs
```bash
# Test routes endpoint
curl http://localhost:5000/api/routes | jq '.[0]'

# Test nearby routes
curl "http://localhost:5000/api/routes/nearby?lat=-1.2921&lng=36.8219&radius=10" | jq

# Test active routes  
curl http://localhost:5000/api/routes/active | jq
```

---

## 📱 App Testing Steps

### 1. Initial Launch
- **Expected**: Splash screen loads → Sign in screen appears
- **Debug**: Red bug icon should appear in bottom-right corner

### 2. Sign In Process
- **Use test credentials**: Any email/password combination
- **Expected**: Home screen loads with map view

### 3. Map Functionality Testing
- **Expected**: Map loads with user location marker (blue pin)
- **Expected**: Route markers appear (green=start, red=end)
- **Debug**: Tap red bug icon to open debug logs

### 4. Debug Log Analysis
Key logs to look for:
```
✅ MapProvider constructor called
✅ Running on Android platform  
✅ API test successful - received X routes
✅ Location obtained: lat, lng
✅ Fetched X routes
✅ Added X markers to map
```

### 5. Network Detection Testing
The app automatically detects the correct API URL:
- **Web/Desktop**: `http://localhost:5000`
- **Android/iOS**: `http://192.168.100.129:5000`

---

## 🐛 Debug System Features

### In-App Debug Screen
- **Access**: Tap red bug icon (🐛) in bottom-right corner
- **Features**:
  - View real-time logs
  - Copy logs to clipboard
  - Clear logs
  - Generate test logs

### Debug Log Categories
- **INFO**: General information and successful operations
- **WARN**: Warnings and fallback scenarios
- **ERROR**: Errors with stack traces
- **DEBUG**: Detailed debugging information

### Key Debug Logs to Monitor
1. **System Info**: Device details, platform, app version
2. **Network Status**: API connectivity, response times
3. **Location Status**: GPS permissions, location accuracy
4. **Map Initialization**: Google Maps setup, marker placement

---

## 🔍 Troubleshooting Guide

### Map Not Loading
**Check Debug Logs for**:
- `API connectivity test failed` → Backend not accessible
- `No location obtained` → Location permissions issue
- `Google Maps` errors → API key or service issue

**Solutions**:
1. Verify backend is running: `curl http://192.168.100.129:5000/api/routes`
2. Check location permissions in Android settings
3. Ensure device is on same network as development machine

### Backend Connection Issues
**Symptoms**: No route data, API errors in logs

**Solutions**:
1. Check IP address: `ip addr show | grep 192.168`
2. Update app_config.dart if IP changed
3. Restart backend: `./start.sh`
4. Check firewall: `sudo ufw allow 5000`

### Location Issues
**Symptoms**: No blue marker, default location used

**Solutions**:
1. Enable location services in Android settings
2. Grant location permission to the app
3. Test GPS with Google Maps app first

---

## 📊 Expected Test Results

### Successful Test Indicators
- ✅ Map loads within 5-10 seconds
- ✅ Blue user location marker appears
- ✅ 4-6 route markers visible (green/red pairs)
- ✅ Debug logs show successful API calls
- ✅ Route data loads from real backend

### API Data Verification
The app should display routes:
1. **Nairobi City Express** (Westlands ↔ CBD)
2. **Karen - Langata Line** (Karen ↔ CBD)  
3. **Eastlands Connect** (Eastlands ↔ CBD)
4. **Northlands Route** (Kasarani ↔ CBD)

---

## 🚀 Next Steps After Testing

### If Maps Work Successfully
1. Test route selection functionality
2. Test navigation features
3. Verify real-time location tracking
4. Test different device orientations

### If Issues Found
1. Copy debug logs from app
2. Check backend logs: `docker logs mongo-bus-app`
3. Verify network connectivity
4. Submit issue with logs attached

---

## 📁 File Locations

- **APK**: `/home/codename/CascadeProjects/bus-passenger-connect/app-release.apk`
- **Backend**: `/home/codename/CascadeProjects/bus-passenger-connect/backend/`
- **Debug Logs**: Available in-app via debug screen
- **Config**: `/home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect/lib/config/app_config.dart`

---

## 🔧 Development Notes

### Backend API Endpoints
- `GET /api/routes` - All available routes
- `GET /api/routes/nearby?lat=X&lng=Y&radius=Z` - Nearby routes
- `GET /api/routes/active?hours=24` - Recently active routes

### Network Configuration
- **Development IP**: 192.168.100.129:5000
- **Fallback**: localhost:5000 (web only)
- **Auto-detection**: Platform-based in app_config.dart

### Debug System
- **Logger**: `lib/utils/debug_logger.dart`
- **Screen**: `lib/screens/debug_screen.dart`
- **Integration**: MapProvider, ApiService, LocationService

This APK includes comprehensive debug logging to help identify any map loading issues on physical devices.
