import Foundation
import SwiftUI

/// Countdown: Represents a countdown event to a specific date
/// 
/// **What it contains:**
/// - Event name and target date
/// - Calculated days remaining
/// - Whether event repeats yearly (like birthdays)
/// 
/// **Examples:**
/// - "Christmas" - December 25 (yearly)
/// - "Vacation" - July 15, 2026 (one-time)
/// - "Birthday" - March 10 (yearly)
/// 
/// **Storage:**
/// - Saved locally in UserDefaults via CountdownStore
/// - Maximum 20 countdowns can be stored
struct Countdown: Codable, Identifiable {
    let name: String              // Event name (e.g., "Christmas")
    let date: String              // Target date in ISO format
    let yearly: Bool              // True if repeats annually
    let daysLeft: Int             // Calculated days until event
    let nextOccurrence: String    // Next date event occurs
    let isPast: Bool              // True if event has passed
    let message: String           // Status message for display
    
    /// Unique identifier combining name and date
    var id: String {
        name + date
    }
    
    enum CodingKeys: String, CodingKey {
        case name, date, yearly, message
        case daysLeft = "days_left"
        case nextOccurrence = "next_occurrence"
        case isPast = "is_past"
    }
}
