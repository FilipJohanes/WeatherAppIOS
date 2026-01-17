import SwiftUI

struct DailyBriefView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var countdownStore: CountdownStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherStore: WeatherStore
    
    @StateObject private var viewModel: DailyBriefViewModel
    @State private var didAppearOnce = false

    init(weatherService: WeatherService, countdownStore: CountdownStore, locationManager: LocationManager, weatherStore: WeatherStore) {
            // Use the parameters passed into the init, not the class variables
            _viewModel = StateObject(wrappedValue: DailyBriefViewModel(
                weatherService: weatherService,
                countdownStore: countdownStore,
                locationManager: locationManager,
                weatherStore: weatherStore
            ))
        }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {

                        // DEBUG location status banner (main screen)
                        #if DEBUG
                        Text("\(locationManager.status.message)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                        #endif

                        if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error) {
                                Task {
                                    await viewModel.fetchDailyBrief()
                                }
                            }
                        } else {
                            if let weather = viewModel.weather {
                                WeatherCard(
                                    weather: weather,
                                    isCurrentLocation: weatherStore.selectedLocation?.isCurrentLocation ?? false
                                )
                            }
                            
                            if !viewModel.countdowns.isEmpty {
                                CountdownsCard(countdowns: viewModel.countdowns)
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No countdowns yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Go to Events tab to add one")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Trident")
            .refreshable {
                // On pull-to-refresh, also nudge location for fresh weather
                locationManager.requestLocation()
                await viewModel.fetchDailyBrief()
            }
        }
        .task {
            // Run once on first appearance
            guard !didAppearOnce else { return }
            didAppearOnce = true

            // Ensure location flow kicks off early for "Current Location" weather
            locationManager.requestLocation()

            await viewModel.fetchDailyBrief()
        }
        .onChange(of: weatherStore.selectedLocationId) { _ in
            Task {
                // If the user picked current location, ensure location is fresh
                if weatherStore.selectedLocation?.isCurrentLocation == true {
                    locationManager.requestLocation()
                }
                await viewModel.fetchDailyBrief()
            }
        }
    }
}
