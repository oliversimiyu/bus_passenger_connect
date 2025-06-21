# Google Maps Kenya Implementation - Complete Testing Guide

## 🎯 Overview
This guide covers testing the Google Maps implementation for the Bus Passenger Connect mobile app, specifically configured for Kenya with Nairobi as the center point.

## 🔧 Pre-Testing Setup

### 1. Build the APK
```bash
cd /home/codename/CascadeProjects/bus-passenger-connect/bus_passenger_connect

# Clean and prepare
flutter clean
flutter pub get

# Build debug APK
flutter build apk --debug
```

### 2. Install on Android Device
```bash
# Install via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or copy APK to device and install manually
cp build/app/outputs/flutter-apk/app-debug.apk /path/to/device/
```

## 🧪 Testing Scenarios

### Scenario 1: Basic Map Loading
**Goal**: Verify that the map loads properly with actual tiles (not blank/gray)

**Steps**:
1. Open the Bus Passenger Connect app
2. Sign in (use test credentials or create account)
3. Tap "Track Route" button or navigate to map screen
4. Wait for map to initialize

**Expected Results**:
- ✅ Map loads with actual Google Maps tiles
- ✅ Map centers on Nairobi, Kenya (-1.2921, 36.8219)
- ✅ No blank or gray areas
- ✅ Kenya landmarks are visible

**If Failed**: Check internet connection and Google Maps API key

---

### Scenario 2: Kenya Location Focus
**Goal**: Verify the app properly focuses on Kenya locations

**Steps**:
1. Open map screen
2. Observe initial camera position
3. Check for Kenya landmarks
4. Test "My Location" button

**Expected Results**:
- ✅ Initial view shows Nairobi city center
- ✅ Landmarks visible: Nairobi CBD, JKIA, Westlands, Karen
- ✅ Coordinates within Kenya bounds (-5.0 to 5.0 lat, 33.0 to 42.0 lng)
- ✅ No references to San Francisco or other non-Kenya locations

---

### Scenario 3: Location Permissions
**Goal**: Test location permission handling

**Steps**:
1. Fresh app install (clear app data if needed)
2. Open map screen
3. When prompted, test different permission responses:
   - Grant permission
   - Deny permission
   - Deny permanently

**Expected Results**:
- ✅ Permission request appears with clear messaging
- ✅ When granted: User location appears on map (if in Kenya)
- ✅ When denied: App shows informative error message
- ✅ App provides options to open settings
- ✅ Always falls back to Nairobi default location

---

### Scenario 4: Route Visualization
**Goal**: Test bus route tracking with Kenya-specific routes

**Steps**:
1. Navigate to map screen
2. Tap the floating action button (bus icon)
3. Select a route from the bottom sheet
4. Observe route visualization

**Expected Results**:
- ✅ Route selection bottom sheet appears
- ✅ Available routes show Kenya locations
- ✅ Route polylines draw on map
- ✅ Route info panel shows distance and time
- ✅ Can end route tracking

---

### Scenario 5: Network Conditions
**Goal**: Test map behavior under different network conditions

**Steps**:
1. Test with WiFi connection
2. Test with mobile data
3. Test with poor connection
4. Test offline behavior

**Expected Results**:
- ✅ Maps load properly on good connections
- ✅ Graceful degradation on poor connections
- ✅ Appropriate error messages when offline
- ✅ Retry mechanisms work

---

### Scenario 6: Error Handling
**Goal**: Test error recovery mechanisms

**Steps**:
1. Turn off location services
2. Turn off internet
3. Test with invalid GPS data
4. Test app recovery when services restored

**Expected Results**:
- ✅ Clear error messages displayed
- ✅ Retry buttons work
- ✅ Settings buttons open appropriate system settings
- ✅ App recovers when services restored

## 📱 Device-Specific Testing

### Android Testing
- Test on different Android versions (API 21+)
- Verify location permissions work correctly
- Check Google Play Services integration
- Test with different screen sizes

### iOS Testing (if available)
- Test on iOS devices
- Verify location permissions work correctly
- Check Info.plist permissions are correct

## 🐛 Common Issues & Solutions

### Issue: Map shows blank/gray area
**Causes**: 
- Missing/invalid Google Maps API key
- Network connectivity issues
- Incorrect API key configuration

**Solutions**:
- Verify API key in `android/app/src/main/AndroidManifest.xml`
- Check internet connection
- Ensure Maps SDK is enabled in Google Cloud Console

### Issue: Wrong location displayed
**Causes**:
- Old cached coordinates
- Incorrect default location settings

**Solutions**:
- Verify `AppConfig.defaultLatitude` and `defaultLongitude` are set to Kenya
- Clear app data and test fresh install

### Issue: Location permissions not working
**Causes**:
- Missing permission declarations
- Incorrect permission handling code

**Solutions**:
- Check `AndroidManifest.xml` has location permissions
- Verify Geolocator plugin is properly configured

## 📊 Test Results Checklist

### Core Functionality
- [ ] Map loads with actual tiles (not blank)
- [ ] Map centers on Nairobi, Kenya
- [ ] Kenya landmarks are visible
- [ ] Location permissions work correctly
- [ ] Route visualization displays properly

### User Experience
- [ ] Loading states are informative
- [ ] Error messages are clear and actionable
- [ ] Retry mechanisms work
- [ ] Navigation is smooth
- [ ] Performance is acceptable

### Technical Requirements
- [ ] GPS tracking works when permitted
- [ ] Falls back to Kenya default when GPS unavailable
- [ ] Network error handling works
- [ ] App doesn't crash under any scenario
- [ ] Memory usage is reasonable

## 🚀 Success Criteria

The Google Maps implementation is considered successful when:

1. **Maps load reliably** on mobile devices without blank areas
2. **Kenya focus is maintained** throughout the app experience
3. **Location services work properly** with appropriate permission handling
4. **Route visualization is functional** with Kenya-specific routes
5. **Error handling is robust** with clear user guidance
6. **Performance is acceptable** on target devices

## 📝 Reporting Issues

When reporting issues, include:
- Device model and Android version
- Network connection type
- Exact steps to reproduce
- Screenshots or screen recordings
- Console logs if available

## 🎉 Expected Outcome

After successful testing, users should experience:
- **Reliable map loading** centered on Kenya
- **Smooth location tracking** with proper permissions
- **Clear route visualization** for Kenya bus routes
- **Informative error handling** when issues occur
- **Consistent Kenya-focused experience** throughout the app

The app should now provide a robust, Kenya-focused mapping experience for bus passengers!
