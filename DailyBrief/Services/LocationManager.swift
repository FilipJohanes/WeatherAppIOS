import Foundation
import SwiftUI
import CoreLocation
import Combine

/// LocationManager: Manages device location services for the app
/// 
/// **What it does:**
/// - Requests location permission from the user
/// - Gets the user's current GPS coordinates
/// - Provides location data to weather and other services
/// 
/// **How it works:**
/// - Uses CoreLocation framework to access device location
/// - Publishes location updates using @Published properties
/// - Delegates callbacks to handle authorization and location updates
/// 
/// **Used by:**
/// - WeatherViewModel: To get coordinates for weather API calls
/// - DailyBriefViewModel: To fetch location-based weather data
class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current location of the device (nil if not available yet)
    @Published var location: CLLocation?
    
    /// Current authorization status for location services
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Error message if location fetch fails
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// CoreLocation manager instance
    private let locationManager = CLLocationManager()
    
    // MARK: - Computed Properties
    
    /// Returns true if app has permission to access location
    var isAuthorized: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Initialization
    
    /// Initializes the LocationManager and sets up CoreLocation
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Get current authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        // If authorized, start getting location immediately
        if isAuthorized {
            locationManager.requestLocation()
        } else if authorizationStatus == .notDetermined {
            // Request permission if never asked before
            requestPermission()
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests "When In Use" location permission from user
    /// This triggers the iOS permission dialog
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Starts continuous location updates
    /// Use this for apps that need constant location tracking
    func startUpdating() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    /// Stops continuous location updates
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Requests location once (not continuous)
    /// Use this for apps that only need occasional location
    func requestLocation() {
        guard isAuthorized else {
            requestPermission()
            return
        }
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
// These methods are callbacks from CoreLocation framework

extension LocationManager: CLLocationManagerDelegate {
    
    /// Called when location is successfully retrieved
    /// Updates the published location property with new coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.errorMessage = nil
    }
    
    /// Called when location fetch fails
    /// Sets error message to inform the user
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to get location: \(error.localizedDescription)"
    }
    
    /// Called when user changes location permission in Settings
    /// Automatically requests location if permission is granted
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // If user just granted permission, get location immediately
        if isAuthorized {
            locationManager.requestLocation()
        } else {
            // Clear location if permission is denied
            location = nil
            if authorizationStatus == .denied || authorizationStatus == .restricted {
                errorMessage = "Location access denied. Please enable in Settings."
            }
        }
    }
}
