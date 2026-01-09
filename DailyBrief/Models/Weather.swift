import Foundation
import SwiftUI

struct Weather: Codable {
    let location: String
    let currentTemp: Double
    let feelsLike: Double
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let tempMin: Double
    let tempMax: Double
    let weekForecast: [DayWeather]
    
    var today: DayWeather {
        DayWeather(
            date: nil,
            dayName: "Today",
            tempMax: tempMax,
            tempMin: tempMin,
            precipitationSum: 0,
            precipitationProbability: weekForecast.first?.precipitationProbability ?? 0,
            windSpeedMax: windSpeed,
            condition: condition.rawValue
        )
    }
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
    
    var conditionEnum: WeatherCondition {
        WeatherCondition(rawValue: condition) ?? .clear
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

// MARK: - Weather Condition

enum WeatherCondition: String, Codable {
    case clear = "clear"
    case clouds = "clouds"
    case drizzle = "drizzle"
    case rain = "rain"
    case snow = "snow"
    case thunderstorm = "thunderstorm"
    
    var weatherEmoji: String {
        switch self {
        case .clear: return "☀️"
        case .clouds: return "☁️"
        case .drizzle: return "🌦️"
        case .rain: return "🌧️"
        case .snow: return "❄️"
        case .thunderstorm: return "⛈️"
        }
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
