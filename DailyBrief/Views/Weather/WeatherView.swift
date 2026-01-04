import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
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
                        
                        // Week Forecast Details
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
        .task {
            await viewModel.fetchWeather()
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
