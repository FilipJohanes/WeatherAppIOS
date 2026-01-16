import Foundation
import CoreLocation
import Combine
internal import _LocationEssentials

/// WeatherViewModel: Manages multiple tracked locations and their weather data
/// 
/// **What it does:**
/// - Manages a list of tracked weather locations
/// - Fetches weather for each location
/// - Handles current GPS location + user-added cities
/// - Manages which location displays on home screen
/// 
/// **How it works:**
/// 1. Loads tracked locations from WeatherStore
/// 2. Fetches weather for each location
/// 3. Updates current location with GPS coordinates
/// 4. Publishes combined location/weather data to Views
/// 
/// **Used by:**
/// - WeatherView: List of all tracked locations
/// - DailyBriefView: Shows selected location on home screen
@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// List of locations with their weather data
    @Published var locationWeathers: [LocationWeather] = []
    
    /// True when fetching weather from API
    @Published var isLoading = false
    
    /// Error message to display to user if operations fail
    @Published var errorMessage: String?
    
    /// City name input for adding new locations
    @Published var newCityName: String = ""
    
    /// Suggested cities based on search text
    @Published var citySuggestions: [CLPlacemark] = []
    
    /// True when searching for city suggestions
    @Published var isSearching = false
    
    // MARK: - Dependencies
    
    /// Service that makes API calls to Open-Meteo
    private let weatherService: WeatherService
    
    /// Manager that provides GPS coordinates
    private let locationManager: LocationManager
    
    /// Store that manages tracked locations
    private let weatherStore: WeatherStore
    
    // MARK: - Computed Properties
    
    /// Weather for the location selected for home screen
    var selectedLocationWeather: LocationWeather? {
        return locationWeathers.first { $0.location.isSelectedForHome }
    }
    
    /// Can add more locations
    var canAddMore: Bool {
        return weatherStore.canAddMore
    }
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with required services
    /// - Parameters:
    ///   - weatherService: Service for fetching weather data
    ///   - locationManager: Manager for accessing device location
    ///   - weatherStore: Store for managing tracked locations
    init(weatherService: WeatherService, locationManager: LocationManager, weatherStore: WeatherStore) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.weatherStore = weatherStore
        
        // Load initial locations
        loadTrackedLocations()
        
        // Auto-fetch weather on startup
        Task {
            await fetchAllWeather()
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads tracked locations from store and creates LocationWeather objects
    /// Preserves existing weather data if location already exists
    func loadTrackedLocations() {
        // Create a dictionary of existing weather data by location ID
        let existingWeather = Dictionary(uniqueKeysWithValues: locationWeathers.map { ($0.id, ($0.weather, $0.errorMessage, $0.isLoading)) })
        
        // Map to LocationWeather objects, preserving existing weather data
        locationWeathers = weatherStore.trackedLocations.map { location in
            if let (weather, error, isLoading) = existingWeather[location.id] {
                // Preserve existing weather data but update location details
                return LocationWeather(
                    id: location.id,
                    location: location,
                    weather: weather,
                    errorMessage: error,
                    isLoading: isLoading
                )
            } else {
                // New location - create fresh LocationWeather object
                return LocationWeather(id: location.id, location: location)
            }
        }
    }
    
    /// Fetches weather for all tracked locations
    /// Uses bulk API call for efficiency when multiple locations exist
    func fetchAllWeather() async {
        print("\n🌤️ [WeatherViewModel] === Fetching weather for all locations ===")
        print("   Total locations: \(locationWeathers.count)")
        
        isLoading = true
        errorMessage = nil
        
        // Mark all as loading
        for index in locationWeathers.indices {
            locationWeathers[index].isLoading = true
            locationWeathers[index].errorMessage = nil
        }
        
        // Update current location coordinates first
        await updateCurrentLocation()
        
        // Get non-current locations (current location already fetched)
        let manualLocations = locationWeathers.filter { !$0.location.isCurrentLocation }
        
        // Use bulk API for 2+ manual locations (more efficient than individual calls)
        // This scales automatically from 2 to maxLocations
        if manualLocations.count >= 2 {
            print("   📦 Using BULK API for \(manualLocations.count) locations (scalable: 2-\(weatherStore.maxLocations-1))")
            await fetchWeatherBulk(for: manualLocations)
        } else if manualLocations.count == 1 {
            print("   📍 Using single API call for 1 location")
            // Fetch weather for single manual location
            await withTaskGroup(of: (UUID, Weather?, String?).self) { group in
                for locationWeather in manualLocations {
                    let location = locationWeather.location
                    print("   📍 Queuing API call for: \(location.displayName)")
                    print("      Coordinates: (\(location.latitude ?? 0), \(location.longitude ?? 0))")
                    
                    group.addTask {
                        await self.fetchWeatherForLocation(locationWeather.location)
                    }
                }
                
                // Collect results
                for await (id, weather, error) in group {
                    if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                        let locationName = locationWeathers[index].location.displayName
                        
                        if let weather = weather {
                            print("   ✅ Weather fetched for: \(locationName)")
                            print("      API returned location: \(weather.location)")
                            print("      Temperature: \(weather.currentTemp)°C")
                        } else if let error = error {
                            print("   ❌ Error fetching weather for \(locationName): \(error)")
                        }
                        
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
        }
        
        print("🌤️ [WeatherViewModel] === Weather fetch complete ===\n")
        isLoading = false
    }
    
    /// Fetches weather for multiple locations using bulk API
    private func fetchWeatherBulk(for locations: [LocationWeather]) async {
        // Build array of coordinates
        let coordinates: [(lat: Double, lon: Double)] = locations.compactMap { locationWeather in
            guard let lat = locationWeather.location.latitude,
                  let lon = locationWeather.location.longitude else {
                return nil
            }
            return (lat, lon)
        }
        
        guard !coordinates.isEmpty else { return }
        
        do {
            // Make bulk API call
            let weatherDict = try await weatherService.getWeatherBulk(locations: coordinates)
            
            // Match results to locations
            for locationWeather in locations {
                guard let lat = locationWeather.location.latitude,
                      let lon = locationWeather.location.longitude else {
                    continue
                }
                
                let key = "\(lat),\(lon)"
                
                if let weather = weatherDict[key],
                   let index = locationWeathers.firstIndex(where: { $0.id == locationWeather.id }) {
                    
                    print("   ✅ Bulk weather for: \(locationWeather.location.displayName)")
                    print("      Temperature: \(weather.currentTemp)°C")
                    
                    locationWeathers[index].weather = weather
                    locationWeathers[index].errorMessage = nil
                    locationWeathers[index].isLoading = false
                    
                    // Store in cache
                    weatherStore.updateWeather(weather, for: locationWeather.id)
                }
            }
        } catch {
            print("   ❌ Bulk API error: \(error.localizedDescription)")
            // Fall back to individual calls if bulk fails
            for locationWeather in locations {
                let (id, weather, errorMsg) = await fetchWeatherForLocation(locationWeather.location)
                if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                    locationWeathers[index].weather = weather
                    locationWeathers[index].errorMessage = errorMsg
                    locationWeathers[index].isLoading = false
                    
                    if let weather = weather {
                        weatherStore.updateWeather(weather, for: id)
                    }
                }
            }
        }
    }
    
    /// Fetches weather for a single location
    func fetchWeatherForLocation(_ location: TrackedLocation) async -> (UUID, Weather?, String?) {
        print("   🔄 [fetchWeatherForLocation] Starting for: \(location.displayName)")
        
        // Handle current location (needs GPS)
        if location.isCurrentLocation {
            print("      Type: Current Location (GPS-based)")
            guard let gpsLocation = locationManager.location else {
                print("      ⚠️ GPS location not available yet")
                return (location.id, nil, nil)  // Don't show error for unavailable GPS
            }
            
            print("      GPS: (\(gpsLocation.coordinate.latitude), \(gpsLocation.coordinate.longitude))")
            
            do {
                let weather = try await weatherService.getWeather(
                    lat: gpsLocation.coordinate.latitude,
                    lon: gpsLocation.coordinate.longitude
                )
                print("      ✅ Successfully fetched weather")
                return (location.id, weather, nil)
            } catch {
                print("      ❌ Error: \(error.localizedDescription)")
                return (location.id, nil, error.localizedDescription)
            }
        }
        
        // Handle manual locations
        print("      Type: Manual Location")
        guard let lat = location.latitude, let lon = location.longitude else {
            print("      ❌ Error: Invalid coordinates")
            return (location.id, nil, "Invalid coordinates")
        }
        
        print("      Coordinates: (\(lat), \(lon))")
        
        do {
            let weather = try await weatherService.getWeather(lat: lat, lon: lon)
            print("      ✅ Successfully fetched weather")
            return (location.id, weather, nil)
        } catch {
            print("      ❌ Error: \(error.localizedDescription)")
            return (location.id, nil, error.localizedDescription)
        }
    }
    
    /// Updates current location with GPS coordinates and fetches its weather
    private func updateCurrentLocation() async {
        print("   📍 [updateCurrentLocation] Updating current location...")
        
        // Request location if not available
        if locationManager.location == nil {
            print("      Requesting GPS location...")
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Update current location in store with actual coordinates
        guard let gpsLocation = locationManager.location else {
            print("      ⚠️ GPS location not available")
            return
        }
        
        print("      GPS coordinates: (\(gpsLocation.coordinate.latitude), \(gpsLocation.coordinate.longitude))")
        
        do {
            // Fetch weather for current GPS location
            print("      Fetching weather for GPS location...")
            let weather = try await weatherService.getWeather(
                lat: gpsLocation.coordinate.latitude,
                lon: gpsLocation.coordinate.longitude
            )
            
            print("      ✅ Weather fetched: \(weather.location), \(weather.currentTemp)°C")
            
            // Update store with resolved city name and coordinates
            weatherStore.updateCurrentLocation(
                cityName: weather.location,
                latitude: gpsLocation.coordinate.latitude,
                longitude: gpsLocation.coordinate.longitude
            )
            
            // IMPORTANT: Update the weather in locationWeathers for current location
            if let currentIndex = locationWeathers.firstIndex(where: { $0.location.isCurrentLocation }) {
                let locationId = locationWeathers[currentIndex].location.id
                
                locationWeathers[currentIndex].weather = weather
                locationWeathers[currentIndex].isLoading = false
                locationWeathers[currentIndex].errorMessage = nil
                
                // Store in shared cache for home screen to use
                weatherStore.updateWeather(weather, for: locationId)
                
                // Update the location data too
                let updatedLocation = locationWeathers[currentIndex].location
                locationWeathers[currentIndex].location = TrackedLocation(
                    id: updatedLocation.id,
                    cityName: weather.location,
                    latitude: gpsLocation.coordinate.latitude,
                    longitude: gpsLocation.coordinate.longitude,
                    isCurrentLocation: true,
                    isSelectedForHome: updatedLocation.isSelectedForHome,
                    dateAdded: updatedLocation.dateAdded
                )
                
                print("      ✅ Current location updated in view model")
            }
        } catch {
            print("      ❌ Failed to fetch current location weather: \(error)")
            // Mark current location as error
            if let currentIndex = locationWeathers.firstIndex(where: { $0.location.isCurrentLocation }) {
                locationWeathers[currentIndex].errorMessage = error.localizedDescription
                locationWeathers[currentIndex].isLoading = false
            }
        }
    }
    
    /// Searches for city suggestions based on partial name
    func searchCities(_ query: String) async {
        guard query.count >= 2 else {
            citySuggestions = []
            return
        }
        
        isSearching = true
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            // Filter for cities and limit to 5 results
            citySuggestions = placemarks
                .filter { $0.locality != nil }
                .prefix(5)
                .map { $0 }
        } catch {
            citySuggestions = []
        }
        
        isSearching = false
    }
    
    /// Adds a city from placemark
    func addCityFromPlacemark(_ placemark: CLPlacemark) async {
        guard let cityName = placemark.locality,
              let location = placemark.location else {
            errorMessage = "Invalid location data"
            return
        }
        
        await addCityWithCoordinates(
            cityName: cityName,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    /// Adds a new city to tracked locations
    func addCity(_ cityName: String) async {
        guard !cityName.isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Try geocoding with better formatting
            let geocoder = CLGeocoder()
            let searchString = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
            let placemarks = try await geocoder.geocodeAddressString(searchString)
            
            guard let placemark = placemarks.first,
                  let location = placemark.location else {
                throw WeatherError.cityNotFound
            }
            
            // Use locality, or fall back to administrative area or name
            let resolvedCityName = placemark.locality 
                                ?? placemark.administrativeArea 
                                ?? placemark.name 
                                ?? cityName
            
            await addCityWithCoordinates(
                cityName: resolvedCityName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } catch WeatherStoreError.limitReached {
            errorMessage = "Maximum 10 locations. Delete one to add more."
        } catch WeatherStoreError.duplicateLocation {
            errorMessage = "This location is already in your list."
        } catch {
            errorMessage = "Could not find city: \(cityName)"
        }
        
        isLoading = false
    }
    
    /// Helper to add city with coordinates
    private func addCityWithCoordinates(cityName: String, latitude: Double, longitude: Double) async {
        print("\n➕ [addCityWithCoordinates] Adding city: \(cityName)")
        print("   Coordinates: (\(latitude), \(longitude))")
        
        do {
            // Add to store with resolved city name
            try weatherStore.addCity(
                cityName,
                latitude: latitude,
                longitude: longitude
            )
            
            print("   ✅ Location added to store")
            
            // Reload locations
            loadTrackedLocations()
            
            // Fetch weather for the new location
            if let newLocation = weatherStore.trackedLocations.last {
                print("   🔄 Fetching weather for new location...")
                let (id, weather, error) = await fetchWeatherForLocation(newLocation)
                if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                    locationWeathers[index].weather = weather
                    locationWeathers[index].errorMessage = error
                    
                    if let weather = weather {
                        print("   ✅ Weather fetched: \(weather.location), \(weather.currentTemp)°C")
                    } else if let error = error {
                        print("   ❌ Weather fetch failed: \(error)")
                    }
                }
            }
            
            newCityName = ""
            citySuggestions = []
        } catch {
            // FIX: Instead of throwing, update your UI error property
            print("   ❌ Failed to add city: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Could not add \(cityName). Please try again."
            }
        }
    }
    
    /// Deletes a tracked location
    func deleteLocation(_ location: TrackedLocation) {
        weatherStore.delete(location)
        loadTrackedLocations()
    }
    
    /// Deletes locations at indices
        func deleteLocations(at offsets: IndexSet) {
            // Filter out current location (always at index 0)
            // FIX: Wrap the result of .filter in IndexSet()
            let validOffsets = IndexSet(offsets.filter { index in
                guard index < locationWeathers.count else { return false }
                return !locationWeathers[index].location.isCurrentLocation
            })
            
            guard !validOffsets.isEmpty else { return }
            
            // Now validOffsets is the correct type: IndexSet
            weatherStore.delete(at: validOffsets)
            loadTrackedLocations()
        }
    
    /// Selects a location for home screen display
    func selectForHome(_ location: TrackedLocation) {
        // Update the store first
        weatherStore.selectForHome(location)
        
        // Reload tracked locations to get updated selection state
        loadTrackedLocations()
        
        // Force UI update
        objectWillChange.send()
    }
}
