import SwiftUI

struct WeatherCard: View {
    let weather: Weather
    var isCurrentLocation: Bool = false  // Only show location icon for current location
    @EnvironmentObject var presetStore: WeatherPresetStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isCurrentLocation {
                    Image(systemName: "location.fill")
                }
                Text(weather.location)
                    .font(.headline)
                Spacer()
                Text(weather.today.conditionEnum.weatherEmoji)
                    .font(.title)
            }
            
            // Current Temperature
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(weather.currentTemp))°")
                        .font(.system(size: 48, weight: .bold))
                    if presetStore.preset.includeFeelsLike {
                        Text("Feels like \(Int(weather.feelsLike))°")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            
            // Additional current conditions (if enabled in preset)
            if presetStore.preset.includeHumidity || presetStore.preset.includeWindSpeed {
                HStack(spacing: 20) {
                    if presetStore.preset.includeHumidity {
                        HStack(spacing: 4) {
                            Image(systemName: "humidity.fill")
                                .foregroundColor(.blue)
                            Text("\(weather.humidity)%")
                                .font(.subheadline)
                        }
                    }
                    
                    if presetStore.preset.includeWindSpeed {
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .foregroundColor(.gray)
                            Text("\(Int(weather.windSpeed)) km/h")
                                .font(.subheadline)
                        }
                    }
                }
                .foregroundColor(.secondary)
            }
            
            Divider()
            
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
                
                if presetStore.preset.includePrecipitationProb {
                    VStack {
                        Text("\(weather.today.precipitationProbability)%")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Rain")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if presetStore.preset.includeDailyForecast && !weather.weekForecast.isEmpty {
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
        .background(
            Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)  // Sky blue at 10% opacity
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 1.5)  // Thin white border
        )
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
