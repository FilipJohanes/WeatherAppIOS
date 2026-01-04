import SwiftUI

@main
struct DailyBriefApp: App {
    @StateObject private var apiService = APIService.shared
    
    var body: some Scene {
        WindowGroup {
            if apiService.isAuthenticated {
                MainTabView()
                    .environmentObject(apiService)
            } else {
                LoginView()
                    .environmentObject(apiService)
            }
        }
    }
}
