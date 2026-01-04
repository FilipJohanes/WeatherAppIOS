import SwiftUI

struct WeatherCard: View {
    let weather: Weather
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                Text(weather.location)
                    .font(.headline)
                Spacer()
                Text(weather.today.condition.weatherEmoji)
                    .font(.title)
            }
            
            HStack(spacing: 30) {
                VStack {
                    Text("\(Int(weather.today.tempMax))°")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("High")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(Int(weather.today.tempMin))°")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(weather.today.precipitationProbability)%")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Rain")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !weather.weekForecast.isEmpty {
                Divider()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(weather.weekForecast) { day in
                            WeekDayView(day: day)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct WeekDayView: View {
    let day: DayWeather
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day.dayName ?? "")
                .font(.caption)
                .fontWeight(.medium)
            
            Text(day.condition.weatherEmoji)
                .font(.title2)
            
            Text("\(Int(day.tempMax))°")
                .fontWeight(.bold)
            
            Text("\(Int(day.tempMin))°")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 60)
    }
}
