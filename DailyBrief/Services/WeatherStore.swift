import Foundation
import SwiftUI
import Combine

/// WeatherStore: Local storage manager for tracked weather locations
/// 
/// **What it does:**
/// - Saves user's tracked locations (cities/places)
/// - Enforces 10 location limit
/// - Manages which location displays on home screen
/// - Always includes "Current Location" as first item
/// 
/// **How it works:**
/// - Data stored in UserDefaults as JSON
/// - Changes published to UI via @Published property
/// - No internet/backend required - all data is local
/// 
/// **Storage Details:**
/// - Key: "trackedLocations"
/// - Format: JSON array of TrackedLocation objects
/// - Persists between app launches
/// - Maximum: 10 locations (including current location)
/// 
/// **Used by:**
/// - WeatherViewModel: For managing tracked locations
/// - DailyBriefViewModel: For getting home screen location
class WeatherStore: ObservableObject {
    
    // MARK: - Published Properties
    
    /// List of tracked locations (always includes current location first)
    @Published var trackedLocations: [TrackedLocation] = []
    
    /// ID of the currently selected location (for reactivity in views)
    @Published var selectedLocationId: UUID?
    
    // MARK: - Constants
    
    private let maxLocations = 10
    private let storageKey = "trackedLocations"
    
    // MARK: - Computed Properties
    
    /// The location selected to display on home screen
    var selectedLocation: TrackedLocation? {
        return trackedLocations.first { $0.isSelectedForHome }
    }
    
    /// Current location item (always first in list)
    var currentLocation: TrackedLocation? {
        return trackedLocations.first { $0.isCurrentLocation }
    }
    
    /// Manual (user-added) locations only
    var manualLocations: [TrackedLocation] {
        return trackedLocations.filter { !$0.isCurrentLocation }
    }
    
    /// Check if can add more locations
    var canAddMore: Bool {
        return trackedLocations.count < maxLocations
    }
    
    /// Remaining location slots
    var remainingSlots: Int {
        return maxLocations - trackedLocations.count
    }
    
    // MARK: - Initialization
    
    init() {
        load()
        
        // Ensure current location always exists as first item
        if currentLocation == nil {
            let currentLoc = TrackedLocation.currentLocation()
            trackedLocations.insert(currentLoc, at: 0)
            save()
        }
        
        // Set initial selected location ID
        selectedLocationId = selectedLocation?.id
    }
    
    // MARK: - Public Methods
    
    /// Add a new tracked location
    /// - Checks for duplicates
    /// - Enforces location limit
    /// - Allows duplicate city if one is current location
    func add(_ location: TrackedLocation) throws {
        // Check limit
        guard canAddMore else {
            throw WeatherStoreError.limitReached
        }
        
        // Check for duplicates (special handling for current location)
        if isDuplicate(location) {
            throw WeatherStoreError.duplicateLocation
        }
        
        trackedLocations.append(location)
        save()
    }
    
    /// Add location by city name (fetches coordinates)
    func addCity(_ cityName: String, latitude: Double, longitude: Double) throws {
        let location = TrackedLocation.manualLocation(
            cityName: cityName,
            latitude: latitude,
            longitude: longitude
        )
        try add(location)
    }
    
    /// Update an existing location
    func update(_ location: TrackedLocation) {
        if let index = trackedLocations.firstIndex(where: { $0.id == location.id }) {
            trackedLocations[index] = location
            save()
        }
    }
    
    /// Delete a location
    func delete(_ location: TrackedLocation) {
        // Don't allow deleting current location
        guard !location.isCurrentLocation else { return }
        
        trackedLocations.removeAll { $0.id == location.id }
        
        // If deleted location was selected for home, select current location
        if location.isSelectedForHome, let currentLoc = currentLocation {
            selectForHome(currentLoc)
        }
        
        save()
    }
    
    /// Delete location at index
    func delete(at offsets: IndexSet) {
        // Filter out current location index (index 0)
        let validOffsets = IndexSet(offsets.filter { $0 != 0 })
        
        let locationsToDelete = validOffsets.map { trackedLocations[$0] }
        let wasSelectedDeleted = locationsToDelete.contains { $0.isSelectedForHome }
        
        trackedLocations.remove(atOffsets: validOffsets)
        
        // If deleted location was selected, select current location
        if wasSelectedDeleted, let currentLoc = currentLocation {
            selectForHome(currentLoc)
        }
        
        save()
    }
    
    /// Select a location to display on home screen
    func selectForHome(_ location: TrackedLocation) {
        // Deselect all others and select the specified one
        trackedLocations = trackedLocations.map { loc in
            var updatedLoc = loc
            updatedLoc.isSelectedForHome = (loc.id == location.id)
        // Update selected location ID for reactivity
        selectedLocationId = location.id
        
            return updatedLoc
        }
        
        save()
        
        // Force publish update
        objectWillChange.send()
    }
    
    /// Update current location with actual coordinates and city name
    func updateCurrentLocation(cityName: String, latitude: Double, longitude: Double) {
        guard var currentLoc = currentLocation else { return }
        
        let updatedLocation = TrackedLocation(
            id: currentLoc.id,
            cityName: cityName,
            latitude: latitude,
            longitude: longitude,
            isCurrentLocation: true,
            isSelectedForHome: currentLoc.isSelectedForHome,
            dateAdded: currentLoc.dateAdded
        )
        
        update(updatedLocation)
    }
    
    // MARK: - Private Methods
    
    /// Check if location is duplicate
    private func isDuplicate(_ newLocation: TrackedLocation) -> Bool {
        // If it's current location, check if we already have one
        if newLocation.isCurrentLocation {
            return currentLocation != nil
        }
        
        // For manual locations, check city name (case-insensitive)
        // Allow if current location has same city name
        let cityName = newLocation.cityName.lowercased()
        let manualDuplicate = manualLocations.contains { $0.cityName.lowercased() == cityName }
        
        return manualDuplicate
    }
    
    private func save() {
        do {
            let encoded = try JSONEncoder().encode(trackedLocations)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save tracked locations: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TrackedLocation].self, from: data) else {
            trackedLocations = []
            return
        }
        
        trackedLocations = decoded
    }
    
    /// Clear all locations except current location (useful for testing)
    func clearAll() {
        let currentLoc = currentLocation ?? TrackedLocation.currentLocation()
        trackedLocations = [currentLoc]
        save()
    }
}

// MARK: - Errors

enum WeatherStoreError: LocalizedError {
    case limitReached
    case duplicateLocation
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .limitReached:
            return "Maximum of 10 locations reached. Please delete one to add more."
        case .duplicateLocation:
            return "This location is already in your list."
        case .notFound:
            return "Location not found."
        }
    }
}
