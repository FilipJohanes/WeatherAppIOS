import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            weather = try await apiService.getWeather()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
