import SwiftUI

struct MainTabView: View {
    // 1. Grab the services from the environment
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var countdownStore: CountdownStore
    @EnvironmentObject var weatherStore: WeatherStore
    
    // Track selected tab for programmatic navigation
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 2. Pass them to the views that now require them in their init
            DailyBriefView(
                weatherService: weatherService,
                countdownStore: countdownStore,
                locationManager: locationManager,
                weatherStore: weatherStore
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            WeatherView(
                weatherService: weatherService,
                locationManager: locationManager,
                weatherStore: weatherStore,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("Weather", systemImage: "cloud.sun.fill")
            }
            .tag(1)
            
            CountdownView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}
