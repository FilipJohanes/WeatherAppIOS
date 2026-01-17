import Foundation

/// WeatherPreset: User-configurable weather data parameters
///
/// **What it does:**
/// - Allows users to choose which weather data to fetch
/// - Stores preferences locally
/// - Builds API query parameters dynamically
///
/// **Categories:**
/// - Current conditions (temperature, feels like, humidity)
/// - Wind information (speed, direction, gusts)
/// - Precipitation (rain, snow, probability)
/// - Atmospheric (pressure, visibility, UV index)
/// - Forecast (daily highs/lows, multi-day forecast)
///
    
struct WeatherPreset: Codable, Equatable {
    // MARK: - Current Weather Parameters
    var includeTemperature: Bool = true          // Temperature (always recommended)
    var includeFeelsLike: Bool = true            // Apparent temperature
    var includeHumidity: Bool = true             // Relative humidity
    var includeWeatherCode: Bool = true          // Weather condition code (always needed)
    
    // MARK: - Wind Parameters
    var includeWindSpeed: Bool = true            // Wind speed
    var includeWindDirection: Bool = false       // Wind direction (degrees)
    var includeWindGusts: Bool = false           // Wind gusts
    
    // MARK: - Precipitation Parameters
    var includePrecipitation: Bool = true        // Total precipitation
    var includePrecipitationProb: Bool = true    // Precipitation probability
    var includeRain: Bool = false                // Rain amount specifically
    var includeSnow: Bool = false                // Snowfall amount
    
    // MARK: - Atmospheric Parameters
    var includePressure: Bool = false            // Surface pressure
    var includeVisibility: Bool = false          // Visibility distance
    var includeCloudCover: Bool = false          // Cloud coverage percentage
    var includeUVIndex: Bool = false             // UV index
    
    // MARK: - Forecast Parameters
    var includeDailyForecast: Bool = true        // 7-day forecast (always recommended)
    var forecastDays: Int = 7                    // Number of days (1-16)
    
    /// Default preset with essential weather data
    static let standard = WeatherPreset()
    
    /// Minimal preset (just temperature and condition)
    static let minimal = WeatherPreset(
        includeTemperature: true,
        includeFeelsLike: false,
        includeHumidity: false,
        includeWeatherCode: true,
        includeWindSpeed: false,
        includePrecipitation: false,
        includePrecipitationProb: false,
        includeDailyForecast: true
    )
    
    /// Complete preset (all available data)
    static let complete = WeatherPreset(
        includeTemperature: true,
        includeFeelsLike: true,
        includeHumidity: true,
        includeWeatherCode: true,
        includeWindSpeed: true,
        includeWindDirection: true,
        includeWindGusts: true,
        includePrecipitation: true,
        includePrecipitationProb: true,
        includeRain: true,
        includeSnow: true,
        includePressure: true,
        includeVisibility: true,
        includeCloudCover: true,
        includeUVIndex: true,
        includeDailyForecast: true,
        forecastDays: 7
    )
    
    // MARK: - API Parameter Generation
    
    /// Generates comma-separated string for API "current" parameter
    var currentParameters: String {
        var params: [String] = []
        
        // Essential (always include weather_code for condition detection)
        if includeWeatherCode {
            params.append("weather_code")
        }
        
        if includeTemperature {
            params.append("temperature_2m")
        }
        
        if includeFeelsLike {
            params.append("apparent_temperature")
        }
        
        if includeHumidity {
            params.append("relative_humidity_2m")
        }
        
        // Wind
        if includeWindSpeed {
            params.append("wind_speed_10m")
        }
        
        if includeWindDirection {
            params.append("wind_direction_10m")
        }
        
        if includeWindGusts {
            params.append("wind_gusts_10m")
        }
        
        // Precipitation
        if includePrecipitation {
            params.append("precipitation")
        }
        
        if includeRain {
            params.append("rain")
        }
        
        if includeSnow {
            params.append("snowfall")
        }
        
        // Atmospheric
        if includePressure {
            params.append("surface_pressure")
        }
        
        if includeVisibility {
            params.append("visibility")
        }
        
        if includeCloudCover {
            params.append("cloud_cover")
        }
        
        return params.joined(separator: ",")
    }
    
    /// Generates comma-separated string for API "hourly" parameter
    var hourlyParameters: String {
        var params: [String] = []
        
        if includeTemperature {
            params.append("temperature_2m")
        }
        
        if includePrecipitation {
            params.append("precipitation")
        }
        
        if includePrecipitationProb {
            params.append("precipitation_probability")
        }
        
        if includeRain {
            params.append("rain")
        }
        
        if includeSnow {
            params.append("snowfall")
        }
        
        if includeWindSpeed {
            params.append("wind_speed_10m")
        }
        
        if includeUVIndex {
            params.append("uv_index")
        }
        
        return params.joined(separator: ",")
    }
    
    /// Generates comma-separated string for API "daily" parameter
    var dailyParameters: String {
        guard includeDailyForecast else { return "" }
        
        var params: [String] = []
        
        // Essential for forecast
        params.append("weather_code")
        params.append("temperature_2m_max")
        params.append("temperature_2m_min")
        
        if includePrecipitationProb {
            params.append("precipitation_probability_max")
        }
        
        if includePrecipitation {
            params.append("precipitation_sum")
        }
        
        if includeWindSpeed {
            params.append("wind_speed_10m_max")
        }
        
        if includeUVIndex {
            params.append("uv_index_max")
        }
        
        return params.joined(separator: ",")
    }
    
    /// Description of enabled features
    var enabledFeaturesDescription: String {
        var features: [String] = []
        
        if includeTemperature { features.append("Temperature") }
        if includeFeelsLike { features.append("Feels Like") }
        if includeHumidity { features.append("Humidity") }
        if includeWindSpeed { features.append("Wind") }
        if includePrecipitation || includePrecipitationProb { features.append("Precipitation") }
        if includePressure { features.append("Pressure") }
        if includeVisibility { features.append("Visibility") }
        if includeUVIndex { features.append("UV Index") }
        
        return features.isEmpty ? "Minimal" : features.joined(separator: ", ")
    }
    
    /// Count of enabled features
    var enabledCount: Int {
        var count = 0
        
        if includeTemperature { count += 1 }
        if includeFeelsLike { count += 1 }
        if includeHumidity { count += 1 }
        if includeWindSpeed { count += 1 }
        if includeWindDirection { count += 1 }
        if includeWindGusts { count += 1 }
        if includePrecipitation { count += 1 }
        if includePrecipitationProb { count += 1 }
        if includeRain { count += 1 }
        if includeSnow { count += 1 }
        if includePressure { count += 1 }
        if includeVisibility { count += 1 }
        if includeCloudCover { count += 1 }
        if includeUVIndex { count += 1 }
        
        return count
    }
}
