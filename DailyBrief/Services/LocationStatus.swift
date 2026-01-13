import Foundation

/// LocationStatus: Represents the current status of location services and updates
enum LocationStatus: Equatable {
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
        case .idle:
            return "Location: idle"
        case .servicesDisabled:
            return "Location: Services OFF (enable in Settings)"

        case .requestingPermission:
            return "Location: requesting permission…"
        case .authorizedWhenInUse:
            return "Location: authorized (When In Use)"
        case .authorizedAlways:
            return "Location: authorized (Always)"
        case .denied:
            return "Location: denied (enable in Settings)"
        case .restricted:
            return "Location: restricted (system policy)"

        case .requestingLocation:
            return "Location: requesting one-shot fix…"
        case .updatingLocation:
            return "Location: updating continuously…"

        case .locationReceived(let lat, let lon, let accuracy):
            return String(format: "Location: %.5f, %.5f (±%.0fm)", lat, lon, accuracy)

        case .failed(let msg):
            return "Location: error — \(msg)"
        }
    }
}
