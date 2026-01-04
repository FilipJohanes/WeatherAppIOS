import Foundation

struct Countdown: Codable, Identifiable {
    let name: String
    let date: String
    let yearly: Bool
    let daysLeft: Int
    let nextOccurrence: String
    let isPast: Bool
    let message: String
    
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
