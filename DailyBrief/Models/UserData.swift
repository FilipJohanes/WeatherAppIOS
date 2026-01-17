import Foundation
import UIKit
import Combine

/// UserData: Root data model containing all user-specific app data
///
/// **Structure:**
/// ```
/// UserData
///   ├── userId: String (device identifier)
///   ├── locations: [LocationData] (user's tracked locations with weather)
///   └── lastUpdated: Date (last sync timestamp)
/// ```
///
/// **Storage:**
/// - Stored locally in UserDefaults as JSON
/// - Can be synced to iCloud later if needed
/// - Provides complete backup/restore capability
struct UserData: Codable {
    let userId: String                  // Unique device/user identifier
    var locations: [LocationData]       // All tracked locations with cached weather
    var lastUpdated: Date               // Last data update timestamp
    
    init(userId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
         locations: [LocationData] = [],
         lastUpdated: Date = Date()) {
        self.userId = userId
        self.locations = locations
        self.lastUpdated = lastUpdated
    }
    
    /// Get currently selected location
    var selectedLocation: LocationData? {
        return locations.first { $0.isSelectedForHome }
    }
    
    /// Get current location entry
    var currentLocation: LocationData? {
        return locations.first { $0.isCurrentLocation }
    }
}

/// LocationData: Complete data for a single tracked location
///
/// **Contains:**
/// - Location info (name, coordinates, type)
/// - Cached weather data
/// - Cache metadata (timestamp, expiry)
struct LocationData: Codable, Identifiable {
    let id: UUID
    let cityName: String
    let latitude: Double
    let longitude: Double
    let isCurrentLocation: Bool
    var isSelectedForHome: Bool
    let dateAdded: Date
    
    // Weather cache
    var cachedWeather: Weather?
    var weatherCacheTimestamp: Date?
    let weatherCacheValidityMinutes: Int = 30
    
    init(id: UUID = UUID(),
         cityName: String,
         latitude: Double,
         longitude: Double,
         isCurrentLocation: Bool = false,
         isSelectedForHome: Bool = false,
         dateAdded: Date = Date(),
         cachedWeather: Weather? = nil,
         weatherCacheTimestamp: Date? = nil) {
        self.id = id
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
        self.isSelectedForHome = isSelectedForHome
        self.dateAdded = dateAdded
        self.cachedWeather = cachedWeather
        self.weatherCacheTimestamp = weatherCacheTimestamp
    }
    
    /// Check if weather cache is still valid
    var isWeatherCacheValid: Bool {
        guard let timestamp = weatherCacheTimestamp else { return false }
        let elapsed = Date().timeIntervalSince(timestamp) / 60
        return elapsed < Double(weatherCacheValidityMinutes)
    }
    
    /// Display name for UI
    var displayName: String {
        return isCurrentLocation ? "Current Location" : cityName
    }
    
    /// Convert to TrackedLocation (backward compatibility)
    func toTrackedLocation() -> TrackedLocation {
        return TrackedLocation(
            id: id,
            cityName: cityName,
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: isCurrentLocation,
            isSelectedForHome: isSelectedForHome,
            dateAdded: dateAdded
        )
    }
    
    /// Create from TrackedLocation (backward compatibility)
    static func from(_ location: TrackedLocation, weather: Weather? = nil) -> LocationData {
        return LocationData(
            id: location.id,
            cityName: location.cityName,
            latitude: location.latitude ?? 0.0,
            longitude: location.longitude ?? 0.0,
            isCurrentLocation: location.isCurrentLocation,
            isSelectedForHome: location.isSelectedForHome,
            dateAdded: location.dateAdded,
            cachedWeather: weather,
            weatherCacheTimestamp: weather != nil ? Date() : nil
        )
    }
}

/// UserDataStore: Manages UserData persistence and operations
///
/// **Storage Strategy:**
/// - Primary: UserDefaults (fast, simple, local)
/// - Future: Can add iCloud sync via NSUbiquitousKeyValueStore
/// - Backup: Export/import JSON for data portability
class UserDataStore: ObservableObject {
    @Published var userData: UserData
    
    private let storageKey = "userData_v1"
    private let maxLocations = 10
    
    init() {
        // Load existing data or create new
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(UserData.self, from: data) {
            self.userData = decoded
        } else {
            // Initialize with current location
            let currentLoc = LocationData(
                cityName: "Current Location",
                latitude: 0.0,  // Will be updated when GPS is available
                longitude: 0.0,
                isCurrentLocation: true,
                isSelectedForHome: true
            )
            self.userData = UserData(locations: [currentLoc])
            save()
        }
    }
    
    // MARK: - Location Management
    
    /// Add a new location
    func addLocation(cityName: String, latitude: Double, longitude: Double) throws {
        guard userData.locations.count < maxLocations else {
            throw UserDataError.limitReached
        }
        
        // Check for duplicates (case-insensitive city name)
        let cityNameLower = cityName.lowercased()
        if userData.locations.contains(where: { 
            !$0.isCurrentLocation && $0.cityName.lowercased() == cityNameLower 
        }) {
            throw UserDataError.duplicateLocation
        }
        
        let newLocation = LocationData(
            cityName: cityName,
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: false,
            isSelectedForHome: false
        )
        
        userData.locations.append(newLocation)
        userData.lastUpdated = Date()
        save()
    }
    
    /// Update location (e.g., when GPS coordinates change)
    func updateLocation(id: UUID, cityName: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        guard let index = userData.locations.firstIndex(where: { $0.id == id }) else { return }
        
        var location = userData.locations[index]
        
        if let cityName = cityName {
            location = LocationData(
                id: location.id,
                cityName: cityName,
                latitude: latitude ?? location.latitude,
                longitude: longitude ?? location.longitude,
                isCurrentLocation: location.isCurrentLocation,
                isSelectedForHome: location.isSelectedForHome,
                dateAdded: location.dateAdded,
                cachedWeather: location.cachedWeather,
                weatherCacheTimestamp: location.weatherCacheTimestamp
            )
        } else if let latitude = latitude, let longitude = longitude {
            location = LocationData(
                id: location.id,
                cityName: location.cityName,
                latitude: latitude,
                longitude: longitude,
                isCurrentLocation: location.isCurrentLocation,
                isSelectedForHome: location.isSelectedForHome,
                dateAdded: location.dateAdded,
                cachedWeather: location.cachedWeather,
                weatherCacheTimestamp: location.weatherCacheTimestamp
            )
        }
        
        userData.locations[index] = location
        userData.lastUpdated = Date()
        save()
    }
    
    /// Update weather cache for a location
    func updateWeatherCache(locationId: UUID, weather: Weather) {
        guard let index = userData.locations.firstIndex(where: { $0.id == locationId }) else { return }
        
        var location = userData.locations[index]
        location = LocationData(
            id: location.id,
            cityName: location.cityName,
            latitude: location.latitude,
            longitude: location.longitude,
            isCurrentLocation: location.isCurrentLocation,
            isSelectedForHome: location.isSelectedForHome,
            dateAdded: location.dateAdded,
            cachedWeather: weather,
            weatherCacheTimestamp: Date()
        )
        
        userData.locations[index] = location
        userData.lastUpdated = Date()
        save()
    }
    
    /// Select location for home screen
    func selectForHome(locationId: UUID) {
        for index in userData.locations.indices {
            var location = userData.locations[index]
            location = LocationData(
                id: location.id,
                cityName: location.cityName,
                latitude: location.latitude,
                longitude: location.longitude,
                isCurrentLocation: location.isCurrentLocation,
                isSelectedForHome: location.id == locationId,
                dateAdded: location.dateAdded,
                cachedWeather: location.cachedWeather,
                weatherCacheTimestamp: location.weatherCacheTimestamp
            )
            userData.locations[index] = location
        }
        
        userData.lastUpdated = Date()
        save()
    }
    
    /// Delete a location
    func deleteLocation(id: UUID) {
        guard let location = userData.locations.first(where: { $0.id == id }),
              !location.isCurrentLocation else { return }
        
        let wasSelected = location.isSelectedForHome
        
        userData.locations.removeAll { $0.id == id }
        
        // If deleted location was selected, select current location
        if wasSelected, let currentIndex = userData.locations.firstIndex(where: { $0.isCurrentLocation }) {
            selectForHome(locationId: userData.locations[currentIndex].id)
        }
        
        userData.lastUpdated = Date()
        save()
    }
    
    // MARK: - Persistence
    
    /// Save to UserDefaults
    func save() {
        do {
            let encoded = try JSONEncoder().encode(userData)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("❌ Failed to save UserData: \(error)")
        }
    }
    
    /// Export data as JSON (for backup/debugging)
    func exportJSON() -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(userData)
            return String(data: data, encoding: .utf8)
        } catch {
            print("❌ Failed to export JSON: \(error)")
            return nil
        }
    }
    
    /// Clear all data (for testing)
    func clearAll() {
        let currentLoc = LocationData(
            cityName: "Current Location",
            latitude: 0.0,
            longitude: 0.0,
            isCurrentLocation: true,
            isSelectedForHome: true
        )
        userData = UserData(locations: [currentLoc])
        save()
    }
}

// MARK: - Errors

enum UserDataError: LocalizedError {
    case limitReached
    case duplicateLocation
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .limitReached:
            return "Maximum of 10 locations reached."
        case .duplicateLocation:
            return "This location is already tracked."
        case .notFound:
            return "Location not found."
        }
    }
}
