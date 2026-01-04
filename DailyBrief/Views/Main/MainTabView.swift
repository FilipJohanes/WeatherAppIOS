import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DailyBriefView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            WeatherView()
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
