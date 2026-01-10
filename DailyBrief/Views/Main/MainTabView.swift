import SwiftUI

struct MainTabView: View {
    // 1. Grab the services from the environment
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var countdownStore: CountdownStore
    @EnvironmentObject var weatherStore: WeatherStore

    var body: some View {
        TabView {
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
            
            WeatherView(
                weatherService: weatherService,
                locationManager: locationManager,
                weatherStore: weatherStore
            )
            .tabItem {
                Label("Weather", systemImage: "cloud.sun.fill")
            }
            
            CountdownView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
