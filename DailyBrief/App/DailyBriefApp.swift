import SwiftUI

@main
struct DailyBriefApp: App {
    // Stage 1 MVP: No authentication, direct to main app
    @StateObject private var weatherService = WeatherService()
    @StateObject private var countdownStore = CountdownStore()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(weatherService)
                .environmentObject(countdownStore)
                .environmentObject(locationManager)
        }
    }
}
