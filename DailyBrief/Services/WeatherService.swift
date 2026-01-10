import Foundation
import SwiftUI
import Combine
import CoreLocation

/// WeatherService: Handles all weather data fetching from Open-Meteo API
/// 
/// **What it does:**
/// - Fetches current weather and 7-day forecast
/// - Converts GPS coordinates to city names (reverse geocoding)
/// - Caches weather data to reduce API calls
/// 
/// **API Details:**
/// - Provider: Open-Meteo (https://open-meteo.com)
/// - Cost: FREE - no API key required!
/// - No backend server needed - direct API calls from app
/// 
/// **Caching:**
/// - Weather cached for 30 minutes
/// - Reduces unnecessary API calls
/// - Improves app performance and responsiveness
/// 
/// **Used by:**
/// - WeatherViewModel: For weather screen
/// - DailyBriefViewModel: For home screen weather

class WeatherService: ObservableObject {
    @Published var lastUpdated: Date?
    
    // MARK: - Configuration
    // Open-Meteo API - Free, no API key required!
    // Documentation: https://open-meteo.com/en/docs
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    // MARK: - Cache
    private let cacheKey = "cachedWeather"
    private let cacheTimestamp = "weatherCacheTimestamp"
    private let cacheValidityMinutes = 30 // Cache for 30 minutes
    
    // MARK: - Public Methods
    
    /// Fetch current weather and forecast for GPS coordinates
    /// Checks cache first, then fetches from API if needed
    /// - Parameters:
    ///   - lat: Latitude coordinate
    ///   - lon: Longitude coordinate
    /// - Returns: Weather object with current conditions and 7-day forecast
    func getWeather(lat: Double, lon: Double) async throws -> Weather {
        // Check cache first
        if let cachedWeather = loadCachedWeather(), isCacheValid() {
            return cachedWeather
        }
        
        // Fetch fresh data
        let weather = try await fetchWeatherFromAPI(lat: lat, lon: lon)
        
        // Cache it
        cacheWeather(weather)
        
        return weather
    }
    
    /// Fetch weather for a specific city by name
    /// First converts city name to coordinates, then fetches weather
    /// - Parameter city: City name (e.g., "San Francisco")
    /// - Returns: Weather object for that city
    func getWeather(city: String) async throws -> Weather {
        let coordinates = try await geocodeCity(city)
        return try await getWeather(lat: coordinates.lat, lon: coordinates.lon)
    }
    
    // MARK: - Private API Methods
    
    /// Makes the actual HTTP call to Open-Meteo API
    /// Builds URL with all required parameters for current + 7-day forecast
    private func fetchWeatherFromAPI(lat: Double, lon: Double) async throws -> Weather {
        // Build URL with all required parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "7")
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherError.networkError
        }
        
        let weatherResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        
        // Get location name from coordinates
        let locationName = try await reverseGeocode(lat: lat, lon: lon)
        
        // Convert to our Weather model
        return convertToWeather(response: weatherResponse, location: locationName)
    }
    
    /// Converts city name to GPS coordinates using iOS CoreLocation
    private func geocodeCity(_ city: String) async throws -> (lat: Double, lon: Double) {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(city)
        
        guard let location = placemarks.first?.location else {
            throw WeatherError.cityNotFound
        }
        
        return (location.coordinate.latitude, location.coordinate.longitude)
    }
    
    /// Converts GPS coordinates to city name (reverse geocoding)
    private func reverseGeocode(lat: Double, lon: Double) async throws -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality ?? "Unknown Location"
        } catch {
            return "Unknown Location"
        }
    }
    
    // MARK: - Data Conversion
    
    /// Converts Open-Meteo API response to our app's Weather model
    /// Transforms API data structure into format used by Views
    private func convertToWeather(response: OpenMeteoResponse, location: String) -> Weather {
        let current = response.current
        let daily = response.daily
        
        // Create week forecast
        var weekForecast: [DayWeather] = []
        
        for i in 0..<min(7, daily.time.count) {
            let dateString = daily.time[i]
            let date = ISO8601DateFormatter().date(from: dateString) ?? Date()
            
            // We must match the EXACT order and TYPES defined in your DayWeather struct
            let dayWeather = DayWeather(
                date: dateString,                                 // 1. date
                dayName: formatDayName(date),                     // 2. dayName
                tempMax: daily.temperature_2m_max[i],             // 3. tempMax
                tempMin: daily.temperature_2m_min[i],             // 4. tempMin
                precipitationSum: 0.0,                            // 5. precipitationSum (New Order)
                precipitationProbability: daily.precipitation_probability_max?[i] ?? 0, // 6. probability
                windSpeedMax: 0.0,                                // 7. windSpeedMax
                condition: weatherCodeToCondition(daily.weather_code[i]).rawValue  // 8. condition (Last)
            )
            weekForecast.append(dayWeather)
        }
        
        return Weather(
            location: location,
            currentTemp: current.temperature_2m,
            feelsLike: current.apparent_temperature,
            condition: weatherCodeToCondition(current.weather_code),
            humidity: current.relative_humidity_2m,
            windSpeed: current.wind_speed_10m,
            tempMin: daily.temperature_2m_min.first ?? current.temperature_2m,
            tempMax: daily.temperature_2m_max.first ?? current.temperature_2m,
            weekForecast: weekForecast
        )
    }
    
    /// Convert Open-Meteo weather codes to our WeatherCondition enum
    /// WMO Weather interpretation codes (WW)
    /// Reference: https://open-meteo.com/en/docs
    /// 
    /// Code Ranges:
    /// - 0: Clear sky
    /// - 1-3: Mainly clear, partly cloudy, overcast
    /// - 45-48: Fog
    /// - 51-67: Drizzle and rain
    /// - 71-86: Snow
    /// - 95-99: Thunderstorm
    private func weatherCodeToCondition(_ code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return .clear
        case 1, 2, 3:
            return .clouds
        case 45, 48:
            return .clouds // Fog
        case 51, 53, 55, 56, 57:
            return .drizzle
        case 61, 63, 65, 66, 67, 80, 81, 82:
            return .rain
        case 71, 73, 75, 77, 85, 86:
            return .snow
        case 95, 96, 99:
            return .thunderstorm
        default:
            return .clear
        }
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Caching
    // Stores weather data locally to reduce API calls and improve speed
    
    /// Saves weather data to UserDefaults with timestamp
    private func cacheWeather(_ weather: Weather) {
        if let encoded = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheTimestamp)
        }
    }
    
    /// Loads weather data from cache if available
    private func loadCachedWeather() -> Weather? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let weather = try? JSONDecoder().decode(Weather.self, from: data) else {
            return nil
        }
        return weather
    }
    
    /// Checks if cached weather is still valid (less than 30 minutes old)
    private func isCacheValid() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: cacheTimestamp) as? Date else {
            return false
        }
        let minutesSince = Date().timeIntervalSince(timestamp) / 60
        return minutesSince < Double(cacheValidityMinutes)
    }
}

// MARK: - API Response Models
// These structs match the JSON structure returned by Open-Meteo API
// Only used internally - app uses Weather model elsewhere

private struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let daily: DailyWeather
    
    struct CurrentWeather: Codable {
        let temperature_2m: Double
        let relative_humidity_2m: Int
        let apparent_temperature: Double
        let weather_code: Int
        let wind_speed_10m: Double
    }
    
    struct DailyWeather: Codable {
        let time: [String]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let precipitation_probability_max: [Int]?
    }
}

// MARK: - Errors

enum WeatherError: LocalizedError {
    case cityNotFound
    case invalidURL
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found. Please check the spelling."
        case .invalidURL:
            return "Invalid URL. Please check your configuration."
        case .networkError:
            return "Network error. Please check your connection."
        }
    }
}
