import Foundation

@MainActor
class CountdownViewModel: ObservableObject {
    @Published var countdowns: [Countdown] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func fetchCountdowns() async {
        isLoading = true
        errorMessage = nil
        
        do {
            countdowns = try await apiService.getCountdowns()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
