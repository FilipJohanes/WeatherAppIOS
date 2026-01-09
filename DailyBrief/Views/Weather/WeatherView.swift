import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationManager: LocationManager
    
    // We declare the StateObject without initializing it here
    @StateObject private var viewModel: WeatherViewModel
    
    // Pass the services into the init
    init(weatherService: WeatherService, locationManager: LocationManager) {
        // We use the underscore to initialize the storage of the StateObject
        _viewModel = StateObject(wrappedValue: WeatherViewModel(
            weatherService: weatherService,
            locationManager: locationManager
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error) {
                            Task { await viewModel.fetchWeather() }
                        }
                    } else if let weather = viewModel.weather {
                        VStack(spacing: 20) {
                            WeatherCard(weather: weather)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("7-Day Forecast")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                ForEach(weather.weekForecast) { day in
                                    WeekDayDetailView(day: day)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Weather")
                .refreshable {
                    await viewModel.fetchWeather()
                }
            }
            .onAppear {
                // DON'T re-assign the viewModel here.
                // Just trigger the action.
                Task {
                    await viewModel.fetchWeather()
                }
            }
        }
    }
}

struct WeekDayDetailView: View {
    let day: DayWeather
    
    var body: some View {
        HStack {
            Text(day.dayName ?? "")
                .frame(width: 80, alignment: .leading)
            
            Text(day.condition.weatherEmoji)
                .font(.title3)
            
            Spacer()
            
            Text("\(day.precipitationProbability)%")
                .foregroundColor(.blue)
                .frame(width: 50)
            
            Text("\(Int(day.tempMax))°/\(Int(day.tempMin))°")
                .fontWeight(.semibold)
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}
