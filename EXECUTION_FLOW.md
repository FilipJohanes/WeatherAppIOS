# Exact Execution Flow - Weather Location System

## � ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│                     WeatherStore                             │
│  (Single Source of Truth for Locations + Weather Cache)     │
├─────────────────────────────────────────────────────────────┤
│  @Published trackedLocations: [TrackedLocation]              │
│  @Published selectedLocationId: UUID?                        │
│  @Published weatherCache: [UUID: Weather]  ← SHARED CACHE    │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────────┐         ┌───────────────────┐
│ WeatherViewModel  │         │ DailyBriefViewModel│
│ (Weather Tab)     │         │ (Home Screen)     │
├───────────────────┤         ├───────────────────┤
│ - Fetches ALL     │────────▶│ - Uses cache      │
│   locations       │ writes  │ - Observes cache  │
│ - Writes to cache │  cache  │ - Auto-updates    │
└───────────────────┘         └───────────────────┘
        │                               │
        ▼                               ▼
┌───────────────────┐         ┌───────────────────┐
│   WeatherView     │         │  DailyBriefView   │
│   (Location List) │         │  (Weather Card)   │
└───────────────────┘         └───────────────────┘
```

---

## �🚀 APP STARTUP FLOW

### Step 1: App Launch
**File:** `DailyBrief/App/DailyBriefApp.swift`
- Environment objects created and passed to MainTabView
- Both ViewModels are initialized

### Step 2: WeatherViewModel Initialization (AUTO-FETCH ALL LOCATIONS)
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 76-87)
```swift
init(weatherService: WeatherService, locationManager: LocationManager, weatherStore: WeatherStore) {
    self.weatherService = weatherService
    self.locationManager = locationManager
    self.weatherStore = weatherStore
    
    // Load initial locations
    loadTrackedLocations()  // ← Loads saved locations from storage
    
    // Auto-fetch weather on startup
    Task {
        await fetchAllWeather()  // ← 🔥 FETCHES WEATHER FOR ALL LOCATIONS ON APP OPEN
    }
}
```

### Step 3: DailyBriefViewModel Initialization (AUTO-FETCH HOME WEATHER)
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 45-63)
```swift
init(weatherService: WeatherService, 
     countdownStore: CountdownStore, 
     locationManager: LocationManager,
     weatherStore: WeatherStore) {
    self.weatherService = weatherService
    self.countdownStore = countdownStore
    self.locationManager = locationManager
    self.weatherStore = weatherStore
    self.countdowns = countdownStore.countdowns
    
    // Observe changes from countdown store
    countdownStore.$countdowns
        .assign(to: &$countdowns)
    
    // Auto-fetch weather on startup
    Task {
        await fetchDailyBrief()  // ← 🔥 FETCHES HOME SCREEN WEATHER ON APP OPEN
    }
}
```

### Step 4: Load Tracked Locations
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 93-109)
```swift
func loadTrackedLocations() {
    // Creates LocationWeather objects from saved locations
    locationWeathers = weatherStore.trackedLocations.map { location in
        // Maps each saved location to LocationWeather with empty weather data
    }
}
```

### Step 4: Fetch All Weather (Auto-executes on startup)
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 115-147)
```swift
func fetchAllWeather() async {
    isLoading = true
    
    // Mark all as loading
    for index in locationWeathers.indices {
        locationWeathers[index].isLoading = true  // ← Shows loading spinner
    }
    
    // Update current location coordinates first
    await updateCurrentLocation()  // ← Gets GPS coordinates
    
    // Fetch weather for each location in parallel
    await withTaskGroup(of: (UUID, Weather?, String?).self) { group in
        for locationWeather in locationWeathers {
            group.addTask {
                await self.fetchWeatherForLocation(locationWeather.location)  // ← API CALL
            }
        }
        
        // Collect results
        for await (id, weather, error) in group {
            if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                locationWeathers[index].weather = weather  // ← UPDATES WEATHER DATA
                locationWeathers[index].isLoading = false
            }
        }
    }
}
```

### Step 5: API Request Per Location
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 149-172)
```swift
func fetchWeatherForLocation(_ location: TrackedLocation) async -> (UUID, Weather?, String?) {
    // Handle current location (needs GPS)
    if location.isCurrentLocation {
        guard let gpsLocation = locationManager.location else {
            return (location.id, nil, nil)
        }
        
        do {
            let weather = try await weatherService.getWeather(  // ← API REQUEST
                lat: gpsLocation.coordinate.latitude,
                lon: gpsLocation.coordinate.longitude
            )
            return (location.id, weather, nil)
        } catch {
            return (location.id, nil, error.localizedDescription)
        }
    }
    
    // Handle manual locations
    guard let lat = location.latitude, let lon = location.longitude else {
        return (location.id, nil, "Invalid coordinates")
    }
    
    do {
        let weather = try await weatherService.getWeather(lat: lat, lon: lon)  // ← API REQUEST
        return (location.id, weather, nil)
    } catch {
        return (location.id, nil, error.localizedDescription)
    }
}
```

---

## 🔄 MANUAL REFRESH FLOW

### Weather Tab Pull-to-Refresh
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 65-67)
```swift
.refreshable {
    await viewModel.fetchAllWeather()  // ← 🔥 REFRESHES ALL LOCATIONS
}
```

### Home Screen Pull-to-Refresh
**File:** `DailyBrief/Views/DailyBrief/DailyBriefView.swift` (Lines 71-73)
```swift
.refreshable {
    await viewModel.fetchDailyBrief()  // ← 🔥 REFRESHES SELECTED LOCATION
}
```

### Weather Tab Navigation (Always Refreshes)
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 68-71)
```swift
.task {
    // Always refresh weather data on appear
    await viewModel.fetchAllWeather()  // ← 🔥 REFRESHES EVERY TIME YOU OPEN WEATHER TAB
}
```

---

## ➕ ADDING NEW LOCATION FLOW

### Step 1: User Opens Add City Sheet
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 53-58)
```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showingAddCity = true }) {  // ← Opens sheet
            Image(systemName: "plus.circle.fill")
        }
    }
}
```

### Step 2: User Types City Name
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 158-163)
```swift
TextField("City name (e.g., San Francisco)", text: $viewModel.newCityName)
    .onChange(of: viewModel.newCityName) { newValue in
        Task {
            await viewModel.searchCities(newValue)  // ← Searches for suggestions
        }
    }
```

### Step 3: User Selects Suggestion or Taps Add
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 188-196)
```swift
Button(action: {
    Task {
        await viewModel.addCityFromPlacemark(placemark)  // ← ADDS CITY
        if viewModel.errorMessage == nil {
            showingAddCity = false
        }
    }
})
```

### Step 4: Add City to Store
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 287-311)
```swift
private func addCityWithCoordinates(cityName: String, latitude: Double, longitude: Double) async {
    do {
        // Add to store with resolved city name
        try weatherStore.addCity(  // ← SAVES TO STORAGE
            cityName,
            latitude: latitude,
            longitude: longitude
        )
        
        // Reload locations
        loadTrackedLocations()  // ← Refreshes list
        
        // Fetch weather for the new location
        if let newLocation = weatherStore.trackedLocations.last {
            let (id, weather, error) = await fetchWeatherForLocation(newLocation)  // ← API CALL
            if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                locationWeathers[index].weather = weather  // ← UPDATES UI
            }
        }
    }
}
```

---

## 🔄 SWITCHING LOCATION FLOW

### Step 1: User Taps Location in Weather Tab
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 86-94)
```swift
ForEach(viewModel.locationWeathers) { locationWeather in
    LocationWeatherRow(
        locationWeather: locationWeather,
        isSelected: locationWeather.location.isSelectedForHome,
        onSelect: {
            viewModel.selectForHome(locationWeather.location)  // ← SELECTS LOCATION
            selectedTab = 0  // ← SWITCHES TO HOME TAB
        }
    )
}
```

### Step 2: Update Selection in ViewModel
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 351-360)
```swift
func selectForHome(_ location: TrackedLocation) {
    // Update the store first
    weatherStore.selectForHome(location)  // ← SAVES SELECTION TO STORAGE
    
    // Reload tracked locations to get updated selection state
    loadTrackedLocations()  // ← Updates locationWeathers with new selection
    
    // Force UI update
    objectWillChange.send()  // ← Triggers UI refresh
}
```

### Step 3: Update Selection in Store
**File:** `DailyBrief/Services/WeatherStore.swift` (Lines 157-172)
```swift
func selectForHome(_ location: TrackedLocation) {
    // Deselect all others and select the specified one
    trackedLocations = trackedLocations.map { loc in
        var updatedLoc = loc
        updatedLoc.isSelectedForHome = (loc.id == location.id)  // ← MARKS SELECTED
        return updatedLoc
    }
    
    // Update selected location ID for reactivity
    selectedLocationId = location.id  // ← TRIGGERS OBSERVER
    
    save()  // ← PERSISTS TO STORAGE
    
    // Force publish update
    objectWillChange.send()
}
```

### Step 4: Home Screen Detects Change
**File:** `DailyBrief/Views/DailyBrief/DailyBriefView.swift` (Lines 80-85)
```swift
.onChange(of: weatherStore.selectedLocationId) { _ in
    // Refresh when selected location changes  ← THIS TRIGGERS
    Task {
        await viewModel.fetchDailyBrief()  // ← FETCHES NEW WEATHER
    }
}
```

### Step 5: Fetch Weather for Selected Location
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 61-76)
```swift
func fetchDailyBrief() async {
    isLoading = true
    errorMessage = nil
    
    // Get the selected location from WeatherStore
    let selectedLocation = weatherStore.selectedLocation  // ← GETS SELECTED LOCATION
    
    // Fetch weather based on selected location
    if let selected = selectedLocation {
        await fetchWeatherForLocation(selected)  // ← FETCHES WEATHER
    } else {
        await fetchCurrentLocationWeather()
    }
    
    countdowns = countdownStore.countdowns
    isLoading = false
}
```

### Step 6: Fetch Weather for Specific Location
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 80-102)
```swift
private func fetchWeatherForLocation(_ location: TrackedLocation) async {
    if location.isCurrentLocation {
        await fetchCurrentLocationWeather()
        return
    }
    
    // For manual locations, use stored coordinates
    guard let lat = location.latitude, let lon = location.longitude else {
        errorMessage = "Invalid location coordinates"
        return
    }
    
    do {
        weather = try await weatherService.getWeather(lat: lat, lon: lon)  // ← API CALL
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### Step 7: Update Home Screen UI
**File:** `DailyBrief/Views/DailyBrief/DailyBriefView.swift` (Lines 39-44)
```swift
// Weather
if let weather = viewModel.weather {
    WeatherCard(
        weather: weather,  // ← DISPLAYS NEW WEATHER
        isCurrentLocation: weatherStore.selectedLocation?.isCurrentLocation ?? false
    )
}
```

---

## 📍 LOCATION ICON DISPLAY LOGIC

### WeatherCard Conditional Icon
**File:** `DailyBrief/Views/DailyBrief/Components/WeatherCard.swift` (Lines 8-12)
```swift
HStack {
    if isCurrentLocation {  // ← ONLY SHOWS FOR CURRENT LOCATION
        Image(systemName: "location.fill")
    }
    Text(weather.location)
```

**When icon shows:**
- `isCurrentLocation = true` → Shows 📍 icon
- `isCurrentLocation = false` → No icon (manual city)

---

## 🔍 DEBUGGING CHECKLIST

If locations are not showing up:
1. Check `weatherStore.trackedLocations` has items
2. Check `viewModel.locationWeathers` is populated
3. Verify `fetchAllWeather()` is being called in init
4. Check console for API errors

If selection doesn't update home screen:
1. Verify `weatherStore.selectedLocationId` changes when tapping location
2. Check `.onChange(of: weatherStore.selectedLocationId)` in DailyBriefView
3. Ensure `weatherStore.selectedLocation` returns correct location
4. Verify `fetchDailyBrief()` is called after selection change

If weather doesn't fetch:
1. Check internet connection
2. Verify API key in WeatherService
3. Check console for error messages
4. Ensure coordinates are valid (not nil)

---

## 📊 DATA FLOW SUMMARY

```
APP LAUNCH
    ↓
WeatherViewModel.init()
    ↓
loadTrackedLocations() → Creates LocationWeather objects
    ↓
fetchAllWeather() → Parallel API calls for all locations
    ↓
UI shows all locations with weather data

USER TAPS LOCATION IN WEATHER TAB
    ↓
viewModel.selectForHome(location)
    ↓
weatherStore.selectForHome(location) → Updates storage
    ↓
weatherStore.selectedLocationId changes
    ↓
DailyBriefView.onChange triggers
    ↓
viewModel.fetchDailyBrief()
    ↓
fetchWeatherForLocation() → API call for selected location
    ↓
weather = new Weather object
    ↓
WeatherCard displays new weather with conditional icon
```

---

## 🎯 KEY REACTIVE PROPERTIES

1. **WeatherStore.selectedLocationId** (`@Published`)
   - Changes when user selects location
   - Observed by DailyBriefView

2. **WeatherViewModel.locationWeathers** (`@Published`)
   - Array of all locations with weather
   - Updates trigger UI refresh in WeatherView

3. **DailyBriefViewModel.weather** (`@Published`)
   - Current weather for home screen
   - Updates when selection changes

---

## 📍 1. REQUESTING CURRENT LOCATION VIA APPLE LOCATION SERVICE

### Overview
The app uses Apple's CoreLocation framework to request and manage the user's current GPS location.

### LocationManager Initialization
**File:** `DailyBrief/Services/LocationManager.swift` (Lines 47-61)
```swift
override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    
    // Get current authorization status
    authorizationStatus = locationManager.authorizationStatus
    
    // If authorized, start getting location immediately
    if isAuthorized {
        locationManager.requestLocation()
    } else if authorizationStatus == .notDetermined {
        // Request permission if never asked before
        requestPermission()
    }
}
```

### Permission Request Flow
**File:** `DailyBrief/Services/LocationManager.swift` (Lines 67-69)
```swift
func requestPermission() {
    locationManager.requestWhenInUseAuthorization()  // ← Triggers iOS permission dialog
}
```

### Location Update Callback
**File:** `DailyBrief/Services/LocationManager.swift` (Lines 97-101)
```swift
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.location = location       // ← Published property updates
    self.errorMessage = nil
}
```

### Authorization Change Handling
**File:** `DailyBrief/Services/LocationManager.swift` (Lines 109-122)
```swift
func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
    
    // If user just granted permission, get location immediately
    if isAuthorized {
        locationManager.requestLocation()
    } else {
        // Clear location if permission is denied
        location = nil
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            errorMessage = "Location access denied. Please enable in Settings."
        }
    }
}
```

### Location Request Flow Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                     APP LAUNCH                                   │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│            LocationManager.init()                                │
│  - Sets delegate to self                                         │
│  - Sets accuracy to kCLLocationAccuracyKilometer                 │
│  - Checks current authorization status                           │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
              ┌───────────┴───────────┐
              ↓                       ↓
┌─────────────────────────┐ ┌─────────────────────────┐
│  isAuthorized = true    │ │ status = .notDetermined │
│  requestLocation()      │ │ requestPermission()     │
└───────────┬─────────────┘ └───────────┬─────────────┘
            ↓                           ↓
┌─────────────────────────┐ ┌─────────────────────────┐
│  CLLocationManager      │ │  iOS Permission Dialog  │
│  fetches GPS coords     │ │  "Allow While Using"    │
└───────────┬─────────────┘ └───────────┬─────────────┘
            ↓                           ↓
┌─────────────────────────┐ ┌─────────────────────────┐
│ didUpdateLocations()    │ │ didChangeAuthorization()│
│ self.location = coords  │ │ if granted → request()  │
└─────────────────────────┘ └─────────────────────────┘
```

---

## 💾 2. WHERE SAVED LOCATIONS ARE STORED WITH WEATHER DATA

### Storage Overview
Locations and weather data are stored in two places:

| Data Type | Storage Location | Key/Property |
|-----------|-----------------|--------------|
| Tracked Locations | UserDefaults | `"trackedLocations"` |
| Weather Cache | In-Memory (WeatherStore) | `weatherCache: [UUID: Weather]` |

### TrackedLocation Model
**File:** `DailyBrief/Models/TrackedLocation.swift` (Lines 17-25)
```swift
struct TrackedLocation: Codable, Identifiable, Equatable {
    let id: UUID
    let cityName: String           // Display name (e.g., "San Francisco")
    let latitude: Double?          // GPS latitude
    let longitude: Double?         // GPS longitude
    let isCurrentLocation: Bool    // True if this tracks device GPS
    var isSelectedForHome: Bool    // True if shown on home screen
    let dateAdded: Date            // When location was added
}
```

### WeatherStore - Persistent Storage (UserDefaults)
**File:** `DailyBrief/Services/WeatherStore.swift` (Lines 231-240)
```swift
private func save() {
    do {
        let encoded = try JSONEncoder().encode(trackedLocations)
        UserDefaults.standard.set(encoded, forKey: storageKey)  // Key: "trackedLocations"
    } catch {
        print("Failed to save tracked locations: \(error)")
    }
}

private func load() {
    guard let data = UserDefaults.standard.data(forKey: storageKey),
          let decoded = try? JSONDecoder().decode([TrackedLocation].self, from: data) else {
        trackedLocations = []
        return
    }
    trackedLocations = decoded
}
```

### WeatherStore - In-Memory Weather Cache
**File:** `DailyBrief/Services/WeatherStore.swift` (Lines 36-37)
```swift
/// Cached weather data for each location (keyed by location ID)
@Published var weatherCache: [UUID: Weather] = [:]
```

### Cache Operations
**File:** `DailyBrief/Services/WeatherStore.swift` (Lines 76-87)
```swift
/// Update weather for a specific location
func updateWeather(_ weather: Weather, for locationId: UUID) {
    weatherCache[locationId] = weather
    objectWillChange.send()
}

/// Get weather for a specific location
func getWeather(for locationId: UUID) -> Weather? {
    return weatherCache[locationId]
}

/// Clear all cached weather
func clearWeatherCache() {
    weatherCache.removeAll()
}
```

### Storage Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                       WeatherStore                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  @Published trackedLocations: [TrackedLocation]           │   │
│  │  ┌───────────────────────────────────────────────────┐    │   │
│  │  │ ID: UUID-1          │ ID: UUID-2                   │   │   │
│  │  │ cityName: "Current" │ cityName: "New York"         │   │   │
│  │  │ isCurrentLocation: ✓│ isCurrentLocation: ✗         │   │   │
│  │  │ isSelectedForHome: ✓│ isSelectedForHome: ✗         │   │   │
│  │  │ lat: 37.77, lon: -122.4│ lat: 40.71, lon: -74.0    │   │   │
│  │  └───────────────────────────────────────────────────┘    │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │ save() / load()                  │
│                               ↓                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              UserDefaults (Persistent)                    │   │
│  │              Key: "trackedLocations"                      │   │
│  │              Format: JSON encoded [TrackedLocation]       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  @Published weatherCache: [UUID: Weather]                 │   │
│  │  ┌───────────────────────────────────────────────────┐    │   │
│  │  │ UUID-1 → Weather(temp: 72°, condition: .clear)     │   │   │
│  │  │ UUID-2 → Weather(temp: 45°, condition: .clouds)    │   │   │
│  │  └───────────────────────────────────────────────────┘    │   │
│  │  (In-Memory Only - Not Persisted to Disk)                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌐 3. REQUESTING OPEN-METEO API FOR ALL LOCATIONS

### API Configuration
**File:** `DailyBrief/Services/WeatherService.swift` (Lines 30-31)
```swift
// Open-Meteo API - Free, no API key required!
private let baseURL = "https://api.open-meteo.com/v1/forecast"
```

### Parallel Fetch for All Locations
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 106-135)
```swift
func fetchAllWeather() async {
    isLoading = true
    errorMessage = nil
    
    // Mark all as loading
    for index in locationWeathers.indices {
        locationWeathers[index].isLoading = true
        locationWeathers[index].errorMessage = nil
    }
    
    // Update current location coordinates first
    await updateCurrentLocation()
    
    // Fetch weather for each location in parallel
    await withTaskGroup(of: (UUID, Weather?, String?).self) { group in
        for locationWeather in locationWeathers {
            // Skip current location - already fetched in updateCurrentLocation
            if locationWeather.location.isCurrentLocation {
                continue
            }
            group.addTask {
                await self.fetchWeatherForLocation(locationWeather.location)
            }
        }
        
        // Collect results
        for await (id, weather, error) in group {
            if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                locationWeathers[index].weather = weather
                locationWeathers[index].errorMessage = error
                locationWeathers[index].isLoading = false
                
                // Store in shared cache for home screen to use
                if let weather = weather {
                    weatherStore.updateWeather(weather, for: id)
                }
            }
        }
    }
    
    isLoading = false
}
```

### API Request Construction
**File:** `DailyBrief/Services/WeatherService.swift` (Lines 73-92)
```swift
private func fetchWeatherFromAPI(lat: Double, lon: Double) async throws -> Weather {
    // Build URL with all required parameters
    var components = URLComponents(string: baseURL)!
    components.queryItems = [
        URLQueryItem(name: "latitude", value: "\(lat)"),
        URLQueryItem(name: "longitude", value: "\(lon)"),
        URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
        URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
        URLQueryItem(name: "timezone", value: "auto"),
        URLQueryItem(name: "forecast_days", value: "7")
    ]
    
    guard let url = components.url else {
        throw WeatherError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // ... response handling
}
```

### API Request Flow Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                  fetchAllWeather() Called                        │
│                  (on app launch or refresh)                      │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: Update Current Location                                 │
│  - Gets GPS coordinates from LocationManager                     │
│  - Fetches weather for current location first                    │
│  - Updates weatherStore.weatherCache[currentLocationId]          │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: Parallel Fetch for Saved Locations                      │
│                                                                  │
│  withTaskGroup:                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Location 1  │  │ Location 2  │  │ Location 3  │   ...        │
│  │ (New York)  │  │ (London)    │  │ (Tokyo)     │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         │                │                │                      │
│         ↓                ↓                ↓                      │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Open-Meteo API (api.open-meteo.com)         │    │
│  │                                                          │    │
│  │  GET /v1/forecast?latitude=X&longitude=Y                 │    │
│  │      &current=temperature_2m,weather_code,...            │    │
│  │      &daily=temperature_2m_max,temperature_2m_min,...    │    │
│  │      &timezone=auto&forecast_days=7                      │    │
│  └─────────────────────────────────────────────────────────┘    │
│         │                │                │                      │
│         ↓                ↓                ↓                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Weather     │  │ Weather     │  │ Weather     │              │
│  │ Response 1  │  │ Response 2  │  │ Response 3  │              │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘              │
│         └────────────────┼────────────────┘                      │
│                          ↓                                       │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: Update Cache & UI                                       │
│  - weatherStore.updateWeather(weather, for: locationId)          │
│  - locationWeathers[index].weather = weather                     │
│  - UI automatically updates via @Published                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 4. LOGIC FOR CHANGING METEO WIDGET ON HOME SCREEN

### Selection Trigger (Weather Tab)
**File:** `DailyBrief/Views/Weather/WeatherView.swift` (Lines 86-94)
```swift
ForEach(viewModel.locationWeathers) { locationWeather in
    LocationWeatherRow(
        locationWeather: locationWeather,
        isSelected: locationWeather.location.isSelectedForHome,
        onSelect: {
            viewModel.selectForHome(locationWeather.location)  // ← User taps location
            selectedTab = 0  // ← Switches to Home tab
        }
    )
}
```

### ViewModel Selection Handler
**File:** `DailyBrief/ViewModels/WeatherViewModel.swift` (Lines 351-360)
```swift
func selectForHome(_ location: TrackedLocation) {
    // Update the store first
    weatherStore.selectForHome(location)  // ← Updates storage
    
    // Reload tracked locations to get updated selection state
    loadTrackedLocations()  // ← Refreshes locationWeathers array
    
    // Force UI update
    objectWillChange.send()
}
```

### WeatherStore Selection Update
**File:** `DailyBrief/Services/WeatherStore.swift` (Lines 157-175)
```swift
func selectForHome(_ location: TrackedLocation) {
    // Deselect all others and select the specified one
    trackedLocations = trackedLocations.map { loc in
        var updatedLoc = loc
        updatedLoc.isSelectedForHome = (loc.id == location.id)
        return updatedLoc
    }
    
    // Update selected location ID for reactivity
    selectedLocationId = location.id  // ← TRIGGERS OBSERVERS
    
    save()  // ← Persists to UserDefaults
    
    // Force publish update
    objectWillChange.send()
}
```

### Widget Selection Flow Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│  USER TAPS LOCATION ROW IN WEATHER TAB                          │
│  (e.g., "New York" row in WeatherView)                          │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  viewModel.selectForHome(location)                               │
│  File: WeatherViewModel.swift                                    │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  weatherStore.selectForHome(location)                            │
│  File: WeatherStore.swift                                        │
│                                                                  │
│  1. Iterate all trackedLocations                                 │
│  2. Set isSelectedForHome = FALSE for all                        │
│  3. Set isSelectedForHome = TRUE for tapped location             │
│  4. Update selectedLocationId = location.id                      │
│  5. save() → UserDefaults                                        │
│  6. objectWillChange.send() → Notifies observers                 │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  AUTOMATIC TAB SWITCH                                            │
│  selectedTab = 0  (Home tab)                                     │
│  File: WeatherView.swift                                         │
└─────────────────────────────────────────────────────────────────┘
```

### Selection State Stored
```
Before Selection:                    After Selection:
┌────────────────────────────┐      ┌────────────────────────────┐
│ Current Location  [✓]      │      │ Current Location  [ ]      │
│ New York          [ ]      │  →   │ New York          [✓]      │
│ London            [ ]      │      │ London            [ ]      │
└────────────────────────────┘      └────────────────────────────┘

selectedLocationId: UUID-1    →     selectedLocationId: UUID-2
```

---

## 🏠 5. HOME SCREEN METEO WIDGET UPDATE WHEN SCREEN SWITCHED

### Tab View Structure
**File:** `DailyBrief/Views/Main/MainTabView.swift` (Lines 13-49)
```swift
TabView(selection: $selectedTab) {
    DailyBriefView(...)
        .tabItem { Label("Home", systemImage: "house.fill") }
        .tag(0)
    
    WeatherView(...)
        .tabItem { Label("Weather", systemImage: "cloud.sun.fill") }
        .tag(1)
    // ... other tabs
}
```

### Home Screen Observes Selection Changes
**File:** `DailyBrief/Views/DailyBrief/DailyBriefView.swift` (Lines 71-77)
```swift
.onChange(of: weatherStore.selectedLocationId) { _ in
    // Refresh when selected location changes
    Task {
        await viewModel.fetchDailyBrief()  // ← Triggered when selection changes
    }
}
```

### Weather Cache Observation
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 56-62)
```swift
// Observe weather cache changes to update home screen
weatherStore.$weatherCache
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
        self?.updateWeatherFromCache()  // ← Auto-updates when cache changes
    }
    .store(in: &cancellables)
```

### Cache-First Loading Strategy
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 69-93)
```swift
func fetchDailyBrief() async {
    isLoading = true
    errorMessage = nil
    
    // First try to get from cache (instant update!)
    if let cachedWeather = weatherStore.selectedLocationWeather {
        weather = cachedWeather
        isLoading = false
        return
    }
    
    // If cache is empty, fetch directly (fallback)
    let selectedLocation = weatherStore.selectedLocation
    
    if let selected = selectedLocation {
        await fetchWeatherForLocation(selected)
    } else {
        await fetchCurrentLocationWeather()
    }
    
    countdowns = countdownStore.countdowns
    isLoading = false
}
```

### Update From Cache Method
**File:** `DailyBrief/ViewModels/DailyBriefViewModel.swift` (Lines 95-101)
```swift
private func updateWeatherFromCache() {
    if let selected = weatherStore.selectedLocation,
       let cachedWeather = weatherStore.getWeather(for: selected.id) {
        weather = cachedWeather      // ← Updates the @Published weather property
        errorMessage = nil
    }
}
```

### Home Screen Update Flow Diagram
```
┌─────────────────────────────────────────────────────────────────┐
│                  TRIGGER: User switches to Home Tab              │
│                  (or selection changes in Weather Tab)           │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  .onChange(of: weatherStore.selectedLocationId)                  │
│  File: DailyBriefView.swift                                      │
│                                                                  │
│  Detects: selectedLocationId property changed                    │
│  Action: Calls viewModel.fetchDailyBrief()                       │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  fetchDailyBrief() Execution                                     │
│  File: DailyBriefViewModel.swift                                 │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Check: Is weather in cache?                             │    │
│  │  weatherStore.selectedLocationWeather                    │    │
│  └─────────────────────┬─────────────────┬─────────────────┘    │
│                        │ YES             │ NO                    │
│                        ↓                 ↓                       │
│  ┌─────────────────────────┐  ┌─────────────────────────────┐   │
│  │  Use cached weather      │  │  Fetch from API              │   │
│  │  weather = cachedWeather │  │  await fetchWeatherForLoc() │   │
│  │  (Instant - no network)  │  │  (Network request)          │   │
│  └─────────────────────────┘  └─────────────────────────────┘   │
│                        │                 │                       │
│                        └────────┬────────┘                       │
│                                 ↓                                │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  @Published weather Property Updates                             │
│  - SwiftUI observes the change                                   │
│  - WeatherCard re-renders with new data                          │
└─────────────────────────┬───────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│  WeatherCard Displays Updated Weather                            │
│  File: DailyBriefView.swift                                      │
│                                                                  │
│  if let weather = viewModel.weather {                            │
│      WeatherCard(                                                │
│          weather: weather,                                       │
│          isCurrentLocation: weatherStore.selectedLocation?       │
│                            .isCurrentLocation ?? false           │
│      )                                                           │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Complete Tab Switch Sequence
```
Step 1: User selects "New York" in Weather Tab
        ↓
Step 2: weatherStore.selectForHome(newYorkLocation)
        - selectedLocationId = newYork.id
        ↓
Step 3: selectedTab = 0 (programmatic switch to Home)
        ↓
Step 4: DailyBriefView appears
        ↓
Step 5: .onChange(of: weatherStore.selectedLocationId) fires
        ↓
Step 6: viewModel.fetchDailyBrief() called
        ↓
Step 7: Check weatherStore.selectedLocationWeather
        - If cached: Use immediately (no API call)
        - If not cached: Fetch from Open-Meteo API
        ↓
Step 8: viewModel.weather = newYorkWeather
        ↓
Step 9: WeatherCard re-renders with New York weather
        ↓
Step 10: Location icon shows/hides based on isCurrentLocation
```

### Reactive Binding Chain
```
weatherStore.selectedLocationId (changes)
        ↓ @Published
DailyBriefView.onChange (triggered)
        ↓ Task
DailyBriefViewModel.fetchDailyBrief() (called)
        ↓ async
weatherStore.weatherCache (read or API fetch)
        ↓ 
DailyBriefViewModel.weather (updated)
        ↓ @Published
WeatherCard (re-rendered)
```
