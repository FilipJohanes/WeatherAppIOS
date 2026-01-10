import SwiftUI

/// WeatherView: Displays list of tracked weather locations
///
/// **What it shows:**
/// - List of all tracked locations (current location always first)
/// - Weather data for each location
/// - Ability to add new cities
/// - Selection indicator for home screen location
/// - Swipe to delete manual locations
///
/// **Features:**
/// - Current Location (GPS-based, always first, can't delete)
/// - Manual Cities (user-added, can delete)
/// - Star icon shows which location displays on home
/// - Tap location to select for home screen
/// - Pull to refresh all weather data
struct WeatherView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherStore: WeatherStore
    
    @StateObject private var viewModel: WeatherViewModel
    @State private var showingAddCity = false
    
    init(weatherService: WeatherService, locationManager: LocationManager, weatherStore: WeatherStore) {
        _viewModel = StateObject(wrappedValue: WeatherViewModel(
            weatherService: weatherService,
            locationManager: locationManager,
            weatherStore: weatherStore
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Location list
                    if viewModel.locationWeathers.isEmpty {
                        emptyStateView
                    } else {
                        locationListView
                    }
                }
            }
            .navigationTitle("Weather Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCity = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .disabled(!viewModel.canAddMore)
                }
            }
            .sheet(isPresented: $showingAddCity) {
                addCitySheet
            }
            .refreshable {
                await viewModel.fetchAllWeather()
            }
            .onAppear {
                Task {
                    await viewModel.fetchAllWeather()
                }
            }
        }
    }
    
    // MARK: - Location List
    
    private var locationListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }
                
                ForEach(viewModel.locationWeathers) { locationWeather in
                    LocationWeatherRow(
                        locationWeather: locationWeather,
                        isSelected: locationWeather.location.isSelectedForHome,
                        onSelect: {
                            viewModel.selectForHome(locationWeather.location)
                        },
                        onDelete: locationWeather.location.isCurrentLocation ? nil : {
                            viewModel.deleteLocation(locationWeather.location)
                        }
                    )
                }
                
                if !viewModel.canAddMore {
                    Text("Maximum 10 locations reached")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Locations Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add cities to track their weather")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddCity = true }) {
                Label("Add City", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // MARK: - Add City Sheet
    
    private var addCitySheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add a city to track its weather")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                TextField("City name (e.g., San Francisco)", text: $viewModel.newCityName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocapitalization(.words)
                
                if viewModel.isLoading {
                    ProgressView("Adding location...")
                        .padding()
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddCity = false
                        viewModel.newCityName = ""
                        viewModel.errorMessage = nil
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        Task {
                            await viewModel.addCity(viewModel.newCityName)
                            if viewModel.errorMessage == nil {
                                showingAddCity = false
                            }
                        }
                    }
                    .disabled(viewModel.newCityName.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

// MARK: - Location Weather Row

struct LocationWeatherRow: View {
    let locationWeather: LocationWeather
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    // Location name with icon
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if locationWeather.location.isCurrentLocation {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(locationWeather.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if isSelected {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        if locationWeather.location.isCurrentLocation && locationWeather.weather == nil && locationWeather.errorMessage == nil {
                            Text("Location unavailable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Weather info or error
                    if let weather = locationWeather.weather {
                        HStack(spacing: 8) {
                            Text(weather.condition.weatherEmoji)
                                .font(.title2)
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Int(weather.currentTemp))°")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("\(Int(weather.tempMax))° / \(Int(weather.tempMin))°")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else if let error = locationWeather.errorMessage {
                        Text("Error")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if locationWeather.isLoading {
                        ProgressView()
                    }
                    
                    // Delete button (only for manual locations)
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding()
                
                // Expanded weather details if selected
                if isSelected, let weather = locationWeather.weather {
                    Divider()
                    
                    HStack(spacing: 20) {
                        WeatherDetailItem(
                            icon: "drop.fill",
                            label: "Humidity",
                            value: "\(weather.humidity)%"
                        )
                        
                        WeatherDetailItem(
                            icon: "wind",
                            label: "Wind",
                            value: "\(Int(weather.windSpeed)) km/h"
                        )
                        
                        WeatherDetailItem(
                            icon: "thermometer",
                            label: "Feels Like",
                            value: "\(Int(weather.feelsLike))°"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Weather Detail Item

struct WeatherDetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.2))
        .cornerRadius(8)
    }
}
