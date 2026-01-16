# Data Storage & API Call Architecture

## Problem Identified

The app was potentially calling the API with incorrect coordinates or all locations were getting the same (current location) data. This happened because:

1. **Coordinates not being stored properly** when adding locations
2. **API calls using wrong coordinates** for each location
3. **Lack of visibility** into what data was being stored and transmitted

## Solution Implemented

### 1. Data Storage Structure

#### Current Storage (UserDefaults)
```swift
UserDefaults
  └── "trackedLocations" → [TrackedLocation]
       ├── TrackedLocation #1 (Current Location)
       │    ├── id: UUID
       │    ├── cityName: "Current Location"
       │    ├── latitude: 37.7749 (from GPS)
       │    ├── longitude: -122.4194 (from GPS)
       │    ├── isCurrentLocation: true
       │    └── isSelectedForHome: true
       │
       ├── TrackedLocation #2 (Manual)
       │    ├── id: UUID
       │    ├── cityName: "New York"
       │    ├── latitude: 40.7128
       │    ├── longitude: -74.0060
       │    ├── isCurrentLocation: false
       │    └── isSelectedForHome: false
       │
       └── Weather Cache (separate)
            ├── [locationId]: Weather data
            └── [locationId]: Weather data
```

#### New Data Model (Optional - UserData.swift)

Created a comprehensive data model for future use:

```swift
UserData
  ├── userId: String (device ID)
  ├── locations: [LocationData]
  │    └── LocationData
  │         ├── Location info (id, name, coordinates)
  │         ├── cachedWeather: Weather?
  │         ├── weatherCacheTimestamp: Date?
  │         └── isWeatherCacheValid: Bool
  └── lastUpdated: Date
```

**Benefits:**
- Weather data stored with location (no separate cache)
- Each location has its own cache timestamp
- Can be easily synced to iCloud
- Complete backup/restore capability
- Better data integrity

### 2. API Call Flow

#### How Data Flows Through the App

```
1. USER ADDS LOCATION
   ├── User enters "New York"
   ├── App geocodes → (40.7128, -74.0060)
   ├── Creates TrackedLocation with coordinates
   ├── Stores in WeatherStore
   └── Calls API with THESE SPECIFIC coordinates

2. APP FETCHES WEATHER
   ├── WeatherViewModel.fetchAllWeather()
   ├── For each location:
   │    ├── Gets location's latitude/longitude
   │    ├── Calls weatherService.getWeather(lat:lon:)
   │    ├── API returns weather for THOSE coordinates
   │    └── Stores in weatherCache[locationId]
   └── UI displays each location's unique weather

3. HOME SCREEN DISPLAY
   ├── Uses selectedLocation
   ├── Gets weather from cache[selectedLocation.id]
   └── Shows weather for THAT location
```

### 3. Debugging Added

#### Console Logs

Now when you run the app, you'll see detailed logs:

```
🌤️ [WeatherViewModel] === Fetching weather for all locations ===
   Total locations: 3

   📍 [updateCurrentLocation] Updating current location...
      GPS coordinates: (37.7749, -122.4194)
      Fetching weather for GPS location...
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (37.7749, -122.4194)
      URL: https://api.open-meteo.com/v1/forecast?latitude=37.7749&longitude=-122.4194...
      ✅ API call successful
      Resolved location: San Francisco
      Temperature: 15.5°C
      ✅ Current location updated in view model

   📍 Queuing API call for: New York
      Coordinates: (40.7128, -74.0060)
   🔄 [fetchWeatherForLocation] Starting for: New York
      Type: Manual Location
      Coordinates: (40.7128, -74.0060)
   🌐 [WeatherService] Making API call to Open-Meteo
      Coordinates: (40.7128, -74.0060)
      ✅ API call successful
      Resolved location: New York
      Temperature: 5.2°C

📍 [WeatherStore] Updating weather cache for: New York
   Coordinates: (40.7128, -74.0060)
   Weather location: New York
   Temperature: 5.2°C

🌤️ [WeatherViewModel] === Weather fetch complete ===
```

#### What to Look For

**✅ GOOD - Each location has different coordinates:**
```
New York → (40.7128, -74.0060) → 5.2°C
San Francisco → (37.7749, -122.4194) → 15.5°C
London → (51.5074, -0.1278) → 8.1°C
```

**❌ BAD - All locations using same coordinates:**
```
New York → (37.7749, -122.4194) → 15.5°C  ⚠️ Using GPS coords!
San Francisco → (37.7749, -122.4194) → 15.5°C
London → (37.7749, -122.4194) → 15.5°C
```

### 4. Data Inspector Tool

Created a debug view to inspect stored data:

**Location:** `Views/Settings/DataInspectorView.swift`

**Features:**
- View all tracked locations with coordinates
- See cached weather for each location
- Export data as text
- Clear cache or all data
- Verify location/weather associations

**How to Add to App:**

In `SettingsView.swift`, add:
```swift
NavigationLink(destination: DataInspectorView(weatherStore: weatherStore)) {
    Label("Data Inspector", systemImage: "doc.text.magnifyingglass")
}
```

## Testing the Fix

### Step 1: Clear Existing Data
1. Open Settings
2. Go to Data Inspector
3. Tap "Clear All Data"
4. Restart app

### Step 2: Add Test Locations

Add these cities (very different climates):
1. **Miami, FL** - Tropical (usually 25-30°C)
2. **Anchorage, AK** - Arctic (usually -10 to 5°C)
3. **London, UK** - Temperate (usually 5-15°C)

### Step 3: Verify Different Data

**In Console Logs:**
- Each city should show different coordinates
- Each API call should use different coordinates
- Each city should return different temperatures

**In Data Inspector:**
- Each location should have unique coordinates
- Each cached weather should match its city
- "API Location" should match the tracked location name

### Step 4: Check Home Screen

1. Select Miami → Should show ~25-30°C
2. Switch to Anchorage → Should show ~-10 to 5°C
3. Switch to London → Should show ~5-15°C

If all locations show the same temperature, you have the bug!

## Common Issues & Fixes

### Issue 1: All Locations Show Same Weather

**Symptom:** All cities show your current location's weather

**Cause:** 
- Coordinates not being saved when adding location
- API calls using GPS coordinates for all locations

**Debug:**
1. Open Data Inspector
2. Check if manual locations have coordinates
3. Look at console logs during weather fetch
4. Verify each location uses its own coordinates in API call

**Fix:**
- Ensure `addCity()` geocodes and saves coordinates
- Verify `fetchWeatherForLocation()` uses `location.latitude` and `location.longitude`

### Issue 2: Coordinates are (0.0, 0.0)

**Symptom:** Locations added but coordinates are zero

**Cause:** Geocoding failed or coordinates not saved

**Debug:**
```swift
// In addCityWithCoordinates
print("Adding city: \(cityName)")
print("Coordinates: (\(latitude), \(longitude))")  // Should NOT be (0.0, 0.0)
```

**Fix:**
- Check internet connection (geocoding needs network)
- Verify city name is valid
- Check console for geocoding errors

### Issue 3: Cache Shows Wrong Location

**Symptom:** Data Inspector shows "New York" location but cached weather says "San Francisco"

**Cause:** Weather from one location being cached under another location's ID

**Debug:**
```swift
// Verify in fetchWeatherForLocation
print("Fetching for location ID: \(location.id)")
print("Using coordinates: (\(lat), \(lon))")
print("Weather returned for: \(weather.location)")
print("Caching under ID: \(location.id)")
```

**Fix:**
- Ensure correct locationId passed to `updateWeather()`
- Verify no ID collisions or mixups

## Storage Options

### Current: UserDefaults (Implemented)

**Pros:**
- ✅ Simple to implement
- ✅ Fast read/write
- ✅ Survives app restarts
- ✅ No internet needed
- ✅ Works offline

**Cons:**
- ❌ Limited to ~1MB (enough for 100s of locations)
- ❌ No sync across devices
- ❌ Lost if user deletes app

**Best for:** Local storage, single device

### Future: iCloud (UserData.swift prepared for this)

**Pros:**
- ✅ Syncs across user's devices
- ✅ Persists if app deleted
- ✅ Apple handles encryption

**Cons:**
- ❌ Requires user iCloud account
- ❌ More complex implementation
- ❌ Sync conflicts possible

**Best for:** Multi-device users

### Alternative: Core Data

**Pros:**
- ✅ Better for large datasets
- ✅ Query capabilities
- ✅ Can sync with CloudKit

**Cons:**
- ❌ More complex
- ❌ Overkill for simple data
- ❌ Harder to debug

**Best for:** Complex data relationships

## Migration Path

If you want to upgrade to UserData.swift model:

1. **Phase 1 (Current):** Use TrackedLocation + WeatherStore
2. **Phase 2:** Migrate to UserDataStore
   - Keep backward compatibility
   - Migrate existing data on first launch
3. **Phase 3:** Add iCloud sync
   - Use NSUbiquitousKeyValueStore
   - Handle conflict resolution

## Key Files Modified

1. **WeatherStore.swift** - Added debugging logs
2. **WeatherViewModel.swift** - Added detailed API call tracking
3. **WeatherService.swift** - Added API request/response logging
4. **UserData.swift** - New comprehensive data model (optional)
5. **DataInspectorView.swift** - Debug/inspection tool

## Next Steps

1. **Run the app** and check console logs
2. **Add multiple locations** in different regions
3. **Use Data Inspector** to verify coordinates
4. **Verify each location** shows different weather
5. **Report findings** - share console logs showing the issue

If locations still show same data after these changes, the logs will clearly show WHERE the problem is occurring.
