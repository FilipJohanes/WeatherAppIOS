import Foundation
import Combine
internal import _LocationEssentials

/// DailyBriefViewModel: Coordinates weather and countdown data for the home screen
/// 
/// **What it does:**
/// - Shows weather for user's selected location from shared cache
/// - Manages the main "Daily Brief" home screen
/// - Falls back to fetching if cache is empty
/// 
/// **How it works:**
/// - Uses weather data cached by WeatherViewModel in WeatherStore
/// - Only fetches if cache is empty
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
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // Observe weather cache changes to update home screen
        weatherStore.$weatherCache
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Only update if we have valid cached weather for selected location
                guard let self = self,
                      let selected = self.weatherStore.selectedLocation,
                      self.weatherStore.getWeather(for: selected.id) != nil else {
                    return
                }
                self.updateWeatherFromCache()
            }
            .store(in: &cancellables)
        
        // Initial load
        updateWeatherFromCache()
    }
    
    // MARK: - Public Methods
    
    /// Updates weather from shared cache or fetches if not available
    func fetchDailyBrief() async {
        isLoading = true
        errorMessage = nil
        
        // First try to get from cache
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
        
        // Countdowns are already loaded from local storage
        countdowns = countdownStore.countdowns
        
        isLoading = false
    }
    
    /// Updates weather from shared cache (called when cache changes)
    private func updateWeatherFromCache() {
        if let selected = weatherStore.selectedLocation,
           let cachedWeather = weatherStore.getWeather(for: selected.id) {
            weather = cachedWeather
            errorMessage = nil
        }
    }
    
    // MARK: - Private Methods
    
    /// Fetches weather for a specific tracked location (fallback when cache empty)
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
            let fetchedWeather = try await weatherService.getWeather(lat: lat, lon: lon)
            weather = fetchedWeather
            // Store in cache
            weatherStore.updateWeather(fetchedWeather, for: location.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Fetches weather for current GPS location (fallback when cache empty)
    private func fetchCurrentLocationWeather() async {
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Fetch weather if location available
        if let location = locationManager.location {
            do {
                let fetchedWeather = try await weatherService.getWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
                weather = fetchedWeather
                
                // Update weather store with current location info
                weatherStore.updateCurrentLocation(
                    cityName: fetchedWeather.location,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Store in cache
                if let currentLoc = weatherStore.currentLocation {
                    weatherStore.updateWeather(fetchedWeather, for: currentLoc.id)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            weather = nil
            errorMessage = "Location not available"
        }
    }
}
