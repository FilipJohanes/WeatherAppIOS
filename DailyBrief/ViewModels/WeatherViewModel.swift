import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService: WeatherService
    private let locationManager: LocationManager
    
    init(weatherService: WeatherService, locationManager: LocationManager) {
        self.weatherService = weatherService
        self.locationManager = locationManager
    }
    
    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        
        // Request location if not available
        if locationManager.location == nil {
            locationManager.requestLocation()
            
            // Wait a bit for location
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
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
