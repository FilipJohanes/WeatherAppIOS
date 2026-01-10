import Foundation
import Combine
internal import _LocationEssentials

/// DailyBriefViewModel: Coordinates weather and countdown data for the home screen
/// 
/// **What it does:**
/// - Combines weather and countdown information
/// - Manages the main "Daily Brief" home screen
/// - Coordinates data from WeatherService and CountdownStore
/// 
/// **How it works:**
/// - Fetches weather based on current location
/// - Loads countdowns from local storage
/// - Publishes combined data to DailyBriefView
/// 
/// **Used by:**
/// - DailyBriefView: The main home screen of the app
@MainActor
class DailyBriefViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Current weather data
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
    
    // MARK: - Initialization
    
    /// Initializes with required services and sets up data bindings
    init(weatherService: WeatherService, countdownStore: CountdownStore, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.countdownStore = countdownStore
        self.locationManager = locationManager
        self.countdowns = countdownStore.countdowns
        
        // Observe changes from store
        countdownStore.$countdowns
            .assign(to: &$countdowns)
    }
    
    // MARK: - Public Methods
    
    /// Fetches all data for the Daily Brief screen
    /// Combines weather and countdown data into single view
    func fetchDailyBrief() async {
        isLoading = true
        errorMessage = nil
        
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        // Fetch weather
        if let location = locationManager.location {
            do {
                weather = try await weatherService.getWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            errorMessage = "Unable to get your location"
        }
        
        // Countdowns are already loaded from local storage
        countdowns = countdownStore.countdowns
        
        isLoading = false
    }
}
