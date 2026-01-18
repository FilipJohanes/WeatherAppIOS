import Foundation

/// LocationStatus: Represents the current status of location services and updates
enum LocationStatus: Equatable {
    case unknown
    case idle
    case servicesDisabled

    case requestingPermission
    case authorizedWhenInUse
    case authorizedAlways
    case denied
    case restricted

    case requestingLocation
    case updatingLocation

    case locationReceived(lat: Double, lon: Double, accuracyMeters: Double)
    case failed(String)

    var message: String {
        switch self {
        case .unknown:
            return "" // Don't show during initialization
        case .idle:
            return "" // Don't show anything when idle (normal state)
        case .servicesDisabled:
            return "Location: Services OFF (enable in Settings)"

        case .requestingPermission:
            return "Location: requesting permission…"
        case .authorizedWhenInUse:
            return "" // Don't show - authorized is normal state
        case .authorizedAlways:
            return "" // Don't show - authorized is normal state
        case .denied:
            return "Location: denied (enable in Settings)"
        case .restricted:
            return "Location: restricted (system policy)"

        case .requestingLocation:
            return "Location: requesting…"
        case .updatingLocation:
            return "Location: updating…"

        case .locationReceived(let lat, let lon, let accuracy):
            return "" // Don't show coordinates - too technical for users
            // If you want to debug, uncomment:
            // return String(format: "Location: %.5f, %.5f (±%.0fm)", lat, lon, accuracy)

        case .failed(let msg):
            return "Location: error — \(msg)"
        }
    }
}
