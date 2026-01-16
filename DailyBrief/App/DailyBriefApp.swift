import SwiftUI

/// DailyBriefApp: The main entry point of the application
/// 
/// **What it does:**
/// - Initializes the app and creates service instances
/// - Sets up dependency injection via @EnvironmentObject
/// - Defines the app's root view (MainTabView)
/// 
/// **Architecture:**
/// - Creates singletons of core services:
///   - WeatherService: Fetches weather data
///   - CountdownStore: Manages countdown storage
///   - LocationManager: Handles GPS/location
/// - Injects these into the view hierarchy
/// - All child views can access services via @EnvironmentObject
/// 
/// **Note:** @main attribute marks this as the app's entry point
@main
struct DailyBriefApp: App {
    // Stage 1 MVP: No authentication, direct to main app
    
    /// Weather preset store - user's weather data preferences
    @StateObject private var presetStore: WeatherPresetStore
    
    /// Weather service instance - shared across all views
    @StateObject private var weatherService: WeatherService
    
    /// Countdown storage - shared across all views
    @StateObject private var countdownStore: CountdownStore
    
    /// Location manager - shared across all views
    @StateObject private var locationManager: LocationManager
    
    /// Weather store - manages tracked locations
    @StateObject private var weatherStore: WeatherStore
    
    init() {
        // Initialize preset store first
        let preset = WeatherPresetStore()
        _presetStore = StateObject(wrappedValue: preset)
        
        // Initialize weather service with preset store
        _weatherService = StateObject(wrappedValue: WeatherService(presetStore: preset))
        
        // Initialize other services
        _countdownStore = StateObject(wrappedValue: CountdownStore())
        _locationManager = StateObject(wrappedValue: LocationManager())
        _weatherStore = StateObject(wrappedValue: WeatherStore())
    }
    
    var body: some Scene {
        WindowGroup {
            // Root view with all services injected
            MainTabView()
                .environmentObject(weatherService)
                .environmentObject(countdownStore)
                .environmentObject(locationManager)
                .environmentObject(weatherStore)
                .environmentObject(presetStore)
        }
    }
}
