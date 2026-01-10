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
    }
    
    // MARK: - Public Methods
    
    /// Loads tracked locations from store and creates LocationWeather objects
    func loadTrackedLocations() {
        locationWeathers = weatherStore.trackedLocations.map { location in
            LocationWeather(id: location.id, location: location)
        }
    }
    
    /// Fetches weather for all tracked locations
    func fetchAllWeather() async {
        isLoading = true
        errorMessage = nil
        
        // Update current location coordinates first
        await updateCurrentLocation()
        
        // Fetch weather for each location in parallel
        await withTaskGroup(of: (UUID, Weather?, String?).self) { group in
            for locationWeather in locationWeathers {
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
                }
            }
        }
        
        isLoading = false
    }
    
    /// Fetches weather for a single location
    func fetchWeatherForLocation(_ location: TrackedLocation) async -> (UUID, Weather?, String?) {
        // Handle current location (needs GPS)
        if location.isCurrentLocation {
            guard let gpsLocation = locationManager.location else {
                return (location.id, nil, nil)  // Don't show error for unavailable GPS
            }
            
            do {
                let weather = try await weatherService.getWeather(
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
            let weather = try await weatherService.getWeather(lat: lat, lon: lon)
            return (location.id, weather, nil)
        } catch {
            return (location.id, nil, error.localizedDescription)
        }
    }
    
    /// Updates current location with GPS coordinates
    private func updateCurrentLocation() async {
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Update current location in store with actual coordinates
        if let gpsLocation = locationManager.location {
            do {
                let weather = try await weatherService.getWeather(
                    lat: gpsLocation.coordinate.latitude,
                    lon: gpsLocation.coordinate.longitude
                )
                
                weatherStore.updateCurrentLocation(
                    cityName: weather.location,
                    latitude: gpsLocation.coordinate.latitude,
                    longitude: gpsLocation.coordinate.longitude
                )
                
                loadTrackedLocations()
            } catch {
                // Silently fail - current location will show as unavailable
            }
        }
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
            // First fetch weather to verify city exists and get coordinates
            let weather = try await weatherService.getWeather(city: cityName)
            
            // Extract coordinates from the fetched location
            // We'll need to add a geocoding helper
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            
            guard let location = placemarks.first?.location else {
                throw WeatherError.cityNotFound
            }
            
            // Add to store with the resolved city name from weather
            try weatherStore.addCity(
                weather.location,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            // Reload locations
            loadTrackedLocations()
            
            // Fetch weather for the new location
            if let newLocation = weatherStore.trackedLocations.last {
                let (id, weather, error) = await fetchWeatherForLocation(newLocation)
                if let index = locationWeathers.firstIndex(where: { $0.id == id }) {
                    locationWeathers[index].weather = weather
                    locationWeathers[index].errorMessage = error
                }
            }
            
            newCityName = ""
        } catch WeatherStoreError.limitReached {
            errorMessage = "Maximum 10 locations. Delete one to add more."
        } catch WeatherStoreError.duplicateLocation {
            errorMessage = "This location is already in your list."
        } catch {
            errorMessage = "Could not find city: \(cityName)"
        }
        
        isLoading = false
    }
    
    /// Deletes a tracked location
    func deleteLocation(_ location: TrackedLocation) {
        weatherStore.delete(location)
        loadTrackedLocations()
    }
    
    /// Deletes locations at indices
    func deleteLocations(at offsets: IndexSet) {
        weatherStore.delete(at: offsets)
        loadTrackedLocations()
    }
    
    /// Selects a location for home screen display
    func selectForHome(_ location: TrackedLocation) {
        weatherStore.selectForHome(location)
        loadTrackedLocations()
    }
}
