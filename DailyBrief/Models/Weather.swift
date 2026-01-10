import Foundation
import SwiftUI

/// Weather: Main model representing current weather and forecast
/// 
/// **What it contains:**
/// - Current weather conditions (temp, feels like, humidity, wind)
/// - Today's high/low temperatures
/// - 7-day weather forecast
/// 
/// **Data source:**
/// - Populated by WeatherService from Open-Meteo API
/// - Cached locally for 30 minutes to reduce API calls
struct Weather: Codable {
    let location: String           // City name (e.g., "San Francisco")
    let currentTemp: Double        // Current temperature in °C
    let feelsLike: Double          // "Feels like" temperature in °C
    let condition: WeatherCondition // Weather condition (clear, rain, etc.)
    let humidity: Int              // Humidity percentage (0-100)
    let windSpeed: Double          // Wind speed in km/h
    let tempMin: Double            // Today's minimum temperature
    let tempMax: Double            // Today's maximum temperature
    let weekForecast: [DayWeather] // 7-day forecast array
    
    /// Creates a DayWeather object for today using current conditions
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

/// DayWeather: Represents weather forecast for a single day
/// Used in the 7-day forecast display
struct DayWeather: Codable, Identifiable {
    let date: String?                   // ISO date string (e.g., "2026-01-10")
    let dayName: String?                // Display name (e.g., "Monday", "Today")
    let tempMax: Double                 // Maximum temperature for the day
    let tempMin: Double                 // Minimum temperature for the day
    let precipitationSum: Double        // Total precipitation in mm
    let precipitationProbability: Int   // Chance of rain (0-100%)
    let windSpeedMax: Double            // Maximum wind speed for the day
    let condition: String               // Weather condition string
    
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

/// WeatherCondition: Enum representing different weather states
/// Maps to emojis for visual display in the UI
enum WeatherCondition: String, Codable {
    case clear = "clear"
    case clouds = "clouds"
    case drizzle = "drizzle"
    case rain = "rain"
    case snow = "snow"
    case thunderstorm = "thunderstorm"
    
    /// Returns emoji representation of weather condition
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

/// Extension to String for converting weather strings to emojis
/// Used for additional weather conditions not in main enum
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
