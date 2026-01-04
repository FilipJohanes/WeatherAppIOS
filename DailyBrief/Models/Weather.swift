import Foundation

struct Weather: Codable {
    let location: String
    let coordinates: Coordinates
    let timezone: String
    let today: DayWeather
    let weekForecast: [DayWeather]
    let summaryText: String
    
    enum CodingKeys: String, CodingKey {
        case location, coordinates, timezone, today
        case weekForecast = "week_forecast"
        case summaryText = "summary_text"
    }
}

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct DayWeather: Codable, Identifiable {
    let date: String?
    let dayName: String?
    let tempMax: Double
    let tempMin: Double
    let precipitationSum: Double
    let precipitationProbability: Int
    let windSpeedMax: Double
    let condition: String
    
    var id: String {
        date ?? UUID().uuidString
    }
    
    enum CodingKeys: String, CodingKey {
        case date, condition
        case dayName = "day_name"
        case tempMax = "temp_max"
        case tempMin = "temp_min"
        case precipitationSum = "precipitation_sum"
        case precipitationProbability = "precipitation_probability"
        case windSpeedMax = "wind_speed_max"
    }
}

// MARK: - Weather Condition Extension

extension String {
    var weatherEmoji: String {
        switch self {
        case "sunny", "sunny_hot": return "☀️"
        case "cloudy": return "☁️"
        case "rainy", "raining": return "🌧️"
        case "heavy_rain": return "⛈️"
        case "thunderstorm": return "⚡"
        case "snowing": return "❄️"
        case "foggy": return "🌫️"
        case "windy": return "💨"
        case "hot", "heatwave": return "🔥"
        case "cold", "freezing", "blizzard": return "🥶"
        case "mild": return "😊"
        default: return "🌤️"
        }
    }
}
