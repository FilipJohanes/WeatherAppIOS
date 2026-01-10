import Foundation
import SwiftUI

/// TrackedLocation: Represents a saved location for weather tracking
/// 
/// **What it contains:**
/// - Location identifier (city name or coordinates)
/// - Whether it's the current GPS location or manual entry
/// - Selection status for home screen display
/// 
/// **Types:**
/// - Current Location: Automatically updates with GPS (isCurrentLocation = true)
/// - Manual Location: User-added cities (isCurrentLocation = false)
/// 
/// **Storage:**
/// - Saved locally in UserDefaults via WeatherStore
/// - Maximum 10 locations can be tracked
struct TrackedLocation: Codable, Identifiable, Equatable {
    let id: UUID
    let cityName: String           // Display name (e.g., "San Francisco")
    let latitude: Double?          // GPS latitude (nil for current location until fetched)
    let longitude: Double?         // GPS longitude (nil for current location until fetched)
    let isCurrentLocation: Bool    // True if this tracks device GPS
    var isSelectedForHome: Bool    // True if shown on home screen
    let dateAdded: Date            // When location was added
    
    /// Creates a new tracked location
    init(id: UUID = UUID(), 
         cityName: String, 
         latitude: Double? = nil, 
         longitude: Double? = nil, 
         isCurrentLocation: Bool = false, 
         isSelectedForHome: Bool = false,
         dateAdded: Date = Date()) {
        self.id = id
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
        self.isSelectedForHome = isSelectedForHome
        self.dateAdded = dateAdded
    }
    
    /// Creates a tracked location for current GPS position
    static func currentLocation() -> TrackedLocation {
        return TrackedLocation(
            cityName: "Current Location",
            isCurrentLocation: true,
            isSelectedForHome: true  // Default selection
        )
    }
    
    /// Creates a tracked location for a specific city
    static func manualLocation(cityName: String, latitude: Double, longitude: Double) -> TrackedLocation {
        return TrackedLocation(
            cityName: cityName,
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: false
        )
    }
    
    /// Check if this location has valid coordinates
    var hasCoordinates: Bool {
        return latitude != nil && longitude != nil
    }
    
    /// Display name for the location
    var displayName: String {
        return isCurrentLocation ? "Current Location" : cityName
    }
    
    // Equatable conformance (for duplicate checking)
    static func == (lhs: TrackedLocation, rhs: TrackedLocation) -> Bool {
        // Two locations are equal if they're both current location
        if lhs.isCurrentLocation && rhs.isCurrentLocation {
            return true
        }
        // Or if they have the same city name (case-insensitive)
        if !lhs.isCurrentLocation && !rhs.isCurrentLocation {
            return lhs.cityName.lowercased() == rhs.cityName.lowercased()
        }
        return false
    }
}

/// LocationWeather: Combines a tracked location with its weather data
/// This is used to display weather for each tracked location
struct LocationWeather: Identifiable {
    let id: UUID
    let location: TrackedLocation
    var weather: Weather?
    var isLoading: Bool = false
    var errorMessage: String?
    
    /// Display name for UI
    var displayName: String {
        // If we have weather data with a location name, use that for current location
        if location.isCurrentLocation, let weather = weather {
            return weather.location
        }
        return location.displayName
    }
}
