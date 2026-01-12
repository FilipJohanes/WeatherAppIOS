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
            .task {
                // Always refresh weather data on appear
                await viewModel.fetchAllWeather()
            }
        }
    }
    
    // MARK: - Location List
    
    private var locationListView: some View {
        List {
            if let error = viewModel.errorMessage {
                ErrorBanner(message: error)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
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
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            
            if !viewModel.canAddMore {
                Text("Maximum 10 locations reached")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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
    var onDelete: (() -> Void)? = nil  // Optional delete action
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Location name with icon
                HStack(spacing: 8) {
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
                
                Spacer()
                
                // Weather info - each row shows its own weather data
                if let weather = locationWeather.weather {
                    HStack(spacing: 12) {
                        Text(weather.condition.weatherEmoji)
                            .font(.title2)
                        
                        Text("\(Int(weather.currentTemp))°")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                } else if locationWeather.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("--")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let deleteAction = onDelete {
                Button(role: .destructive, action: deleteAction) {
                    Label("Delete", systemImage: "trash")
                }
            }
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
