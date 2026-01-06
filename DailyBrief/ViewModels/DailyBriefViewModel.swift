import Foundation

@MainActor
class DailyBriefViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var countdowns: [Countdown] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService: WeatherService
    private let countdownStore: CountdownStore
    private let locationManager: LocationManager
    
    init(weatherService: WeatherService, countdownStore: CountdownStore, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.countdownStore = countdownStore
        self.locationManager = locationManager
        self.countdowns = countdownStore.countdowns
        
        // Observe changes from store
        countdownStore.$countdowns
            .assign(to: &$countdowns)
    }
    
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
