import SwiftUI

struct DailyBriefView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var countdownStore: CountdownStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherStore: WeatherStore
    
    @StateObject private var viewModel: DailyBriefViewModel

    // Add this init to accept the services
    init(weatherService: WeatherService, countdownStore: CountdownStore, locationManager: LocationManager, weatherStore: WeatherStore) {
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
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error) {
                                Task {
                                    await viewModel.fetchDailyBrief()
                                }
                            }
                        } else {
                            // Weather
                            if let weather = viewModel.weather {
                                WeatherCard(
                                    weather: weather,
                                    isCurrentLocation: weatherStore.selectedLocation?.isCurrentLocation ?? false
                                )
                            }
                            
                            // Countdowns
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
                await viewModel.fetchDailyBrief()
            }
        }
        .onChange(of: weatherStore.selectedLocationId) { _ in
            // Refresh when selected location changes
            Task {
                await viewModel.fetchDailyBrief()
            }
        }
    }
}
