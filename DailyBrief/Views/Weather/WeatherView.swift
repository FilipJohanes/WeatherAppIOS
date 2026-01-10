import SwiftUI
import CoreLocation

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
    @Binding var selectedTab: Int  // For navigation to home
    
    init(weatherService: WeatherService, locationManager: LocationManager, weatherStore: WeatherStore, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: WeatherViewModel(
            weatherService: weatherService,
            locationManager: locationManager,
            weatherStore: weatherStore
        ))
        _selectedTab = selectedTab
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
                            // Navigate to home tab
                            selectedTab = 0
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
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Text("Add a city to track its weather")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    TextField("City name (e.g., San Francisco)", text: $viewModel.newCityName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.words)
                        .onChange(of: viewModel.newCityName) { newValue in
                            Task {
                                await viewModel.searchCities(newValue)
                            }
                        }
                    
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
                }
                
                // City suggestions list
                if !viewModel.citySuggestions.isEmpty && !viewModel.newCityName.isEmpty {
                    Divider()
                        .padding(.top)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            Text("Suggestions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            ForEach(viewModel.citySuggestions, id: \.self) { placemark in
                                Button(action: {
                                    Task {
                                        await viewModel.addCityFromPlacemark(placemark)
                                        if viewModel.errorMessage == nil {
                                            showingAddCity = false
                                        }
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(placemark.locality ?? "Unknown")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            if let country = placemark.country {
                                                Text(country)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                            }
                        }
                    }
                } else if viewModel.isSearching {
                    ProgressView("Searching...")
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddCity = false
                        viewModel.newCityName = ""
                        viewModel.citySuggestions = []
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
        VStack(alignment: .leading, spacing: 0) {
            // Main row - tap to select
            Button(action: onSelect) {
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
            }
            .buttonStyle(.plain)
            
            // Always show weather details section (with placeholder if no weather)
            Divider()
            
            HStack(spacing: 20) {
                if let weather = locationWeather.weather {
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
                } else {
                    // Placeholder to maintain consistent height
                    WeatherDetailItem(
                        icon: "drop.fill",
                        label: "Humidity",
                        value: "--"
                    )
                    
                    WeatherDetailItem(
                        icon: "wind",
                        label: "Wind",
                        value: "--"
                    )
                    
                    WeatherDetailItem(
                        icon: "thermometer",
                        label: "Feels Like",
                        value: "--"
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .frame(height: 70)  // Fixed height for consistency
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
