//
//  WeatherAvatar.swift
//  DailyBrief
//
//  Weather avatar outfit mapping and configuration
//

import Foundation

/// Defines the different outfit styles based on weather conditions
enum WeatherOutfit: String, CaseIterable {
    case sunny
    case rainy
    case snowy
    case cold
    case hot
    case windy
    case cloudy
    
    /// Asset name for the main outfit
    var outfitImageName: String {
        "outfit_\(rawValue)"
    }
    
    /// Asset name for accessories (optional)
    var accessoryImageName: String? {
        switch self {
        case .sunny: return "accessory_sunglasses"
        case .rainy: return "accessory_umbrella"
        case .snowy: return "accessory_hat"
        case .windy: return "accessory_scarf"
        case .cold: return "accessory_scarf"
        default: return nil
        }
    }
    
    /// Should the accessory animate?
    var hasAnimatedAccessory: Bool {
        switch self {
        case .rainy, .windy: return true
        default: return false
        }
    }
    
    /// Description for debugging
    var description: String {
        switch self {
        case .sunny: return "Light summer clothes"
        case .rainy: return "Raincoat with umbrella"
        case .snowy: return "Heavy winter jacket"
        case .cold: return "Warm sweater with scarf"
        case .hot: return "Minimal summer outfit"
        case .windy: return "Windbreaker with scarf"
        case .cloudy: return "Casual everyday outfit"
        }
    }
}

/// Helper to determine outfit based on weather conditions
struct WeatherAvatarMapper {
    
    /// Determine which outfit to wear based on weather
    static func getOutfit(for weather: Weather) -> WeatherOutfit {
        let temp = weather.currentTemp
        let condition = weather.condition
        
        // Priority 1: Weather conditions based on youEnum
        switch condition {
        case .snow:
            return .snowy
        case .rain, .drizzle, .thunderstorm:
            return .rainy
        case .clouds:
            // Check temperature for cloudy days
            if temp < 10 { return .cold }
            return .cloudy
        case .clear:
            // Check temperature for clear days
            if temp >= 28 { return .hot }
            if temp >= 20 { return .sunny }
            if temp < 10 { return .cold }
            return .sunny
        }
    }
    
    
    /// Get outfit with wind consideration if wind speed is available
    static func getOutfit(for weather: Weather, windSpeed: Double?) -> WeatherOutfit {
        // Check for high wind first
        if let wind = windSpeed, wind > 30 {
            return .windy
        }
        
        // Otherwise use standard mapping
        return getOutfit(for: weather)
    }
}

/// Configuration for avatar animations
struct AvatarAnimationConfig {
    // Breathing animation
    let breathingDuration: Double = 3.5
    let breathingScale: CGFloat = 1.02
    
    // Outfit transition
    let outfitTransitionDuration: Double = 0.6
    
    // Accessory animations
    let umbrellaBounceDuration: Double = 1.2
    let scarfSwayDuration: Double = 2.0
    let scarfSwayAngle: Double = 8.0
    
    static let `default` = AvatarAnimationConfig()
}
