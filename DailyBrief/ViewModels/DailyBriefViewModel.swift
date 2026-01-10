import Foundation
import Combine
internal import _LocationEssentials

/// DailyBriefViewModel: Coordinates weather and countdown data for the home screen
/// 
/// **What it does:**
/// - Combines weather and countdown information
/// - Manages the main "Daily Brief" home screen
/// - Shows weather for user's selected location
/// 
/// **How it works:**
/// - Fetches weather for the location selected in WeatherStore
/// - Falls back to current location if no selection
/// - Loads countdowns from local storage
/// - Publishes combined data to DailyBriefView
/// 
/// **Used by:**
/// - DailyBriefView: The main home screen of the app
@MainActor
class DailyBriefViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current weather data for selected location
    @Published var weather: Weather?
    
    /// List of user's countdowns
    @Published var countdowns: [Countdown] = []
    
    /// True while fetching data
    @Published var isLoading = false
    
    /// Error message for user display
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let weatherService: WeatherService
    private let countdownStore: CountdownStore
    private let locationManager: LocationManager
    private let weatherStore: WeatherStore
    
    // MARK: - Initialization
    
    /// Initializes with required services and sets up data bindings
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
    }
    
    // MARK: - Public Methods
    
    /// Fetches all data for the Daily Brief screen
    /// Gets weather for user's selected location (or current if none selected)
    func fetchDailyBrief() async {
        isLoading = true
        errorMessage = nil
        
        // Get the selected location from WeatherStore
        let selectedLocation = weatherStore.selectedLocation
        
        // Fetch weather based on selected location
        if let selected = selectedLocation {
            await fetchWeatherForLocation(selected)
        } else {
            // Fallback: try to get current location weather
            await fetchCurrentLocationWeather()
        }
        
        // Countdowns are already loaded from local storage
        countdowns = countdownStore.countdowns
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Fetches weather for a specific tracked location
    private func fetchWeatherForLocation(_ location: TrackedLocation) async {
        // If it's current location, need GPS
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
            weather = try await weatherService.getWeather(lat: lat, lon: lon)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Fetches weather for current GPS location
    private func fetchCurrentLocationWeather() async {
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Fetch weather if location available
        if let location = locationManager.location {
            do {
                weather = try await weatherService.getWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
                
                // Update weather store with current location info
                weatherStore.updateCurrentLocation(
                    cityName: weather?.location ?? "Unknown",
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            // Location not available - show nil weather (will show empty state)
            weather = nil
        }
    }
}
