# Exact Execution Flow - Weather Location System

## 🚀 APP STARTUP FLOW

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
