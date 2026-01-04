import Foundation

@MainActor
class DailyBriefViewModel: ObservableObject {
    @Published var dailyBrief: DailyBrief?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func fetchDailyBrief() async {
        isLoading = true
        errorMessage = nil
        
        do {
            dailyBrief = try await apiService.getDailyBrief()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
