import Foundation
import Combine
internal import _LocationEssentials

/// WeatherViewModel: Manages weather data and coordinates with services
/// 
/// **What it does:**
/// - Fetches current weather and 7-day forecast from Open-Meteo API
/// - Manages loading states and error messages for the UI
/// - Coordinates between LocationManager and WeatherService
/// 
/// **How it works:**
/// 1. Requests user's location from LocationManager
/// 2. Passes coordinates to WeatherService
/// 3. Publishes weather data to Views for display
/// 
/// **Used by:**
/// - WeatherView: Main weather screen
/// - DailyBriefView: Shows weather summary on home screen
@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current weather data (nil if not loaded yet)
    @Published var weather: Weather?
    
    /// True when fetching weather from API
    @Published var isLoading = false
    
    /// Error message to display to user if fetch fails
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// Service that makes API calls to Open-Meteo
    private let weatherService: WeatherService
    
    /// Manager that provides GPS coordinates
    private let locationManager: LocationManager
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with required services
    /// - Parameters:
    ///   - weatherService: Service for fetching weather data
    ///   - locationManager: Manager for accessing device location
    init(weatherService: WeatherService, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager
    }
    
    // MARK: - Public Methods
    
    /// Fetches weather data for user's current location
    /// This is an async function that:
    /// 1. Requests location if not available
    /// 2. Waits for location (with 2 second timeout)
    /// 3. Calls WeatherService API
    /// 4. Updates UI with result or error
    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            
            // Wait briefly for location (2 seconds)
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        guard let location = locationManager.location else {
            errorMessage = "Unable to get your location. Please enable location services in Settings."
            isLoading = false
            return
        }
        
        do {
            weather = try await weatherService.getWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
