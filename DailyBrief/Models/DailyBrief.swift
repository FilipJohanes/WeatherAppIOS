import Foundation

struct DailyBrief: Codable {
    let user: User
    let modulesEnabled: ModulesEnabled
    let weather: Weather?
    let countdowns: [Countdown]?
    let nameday: Nameday?
    let reminders: [Reminder]?
    let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case user, weather, countdowns, nameday, reminders
        case modulesEnabled = "modules_enabled"
        case generatedAt = "generated_at"
    }
}

struct ModulesEnabled: Codable {
    let weather: Bool
    let countdown: Bool
    let reminder: Bool
}

// MARK: - Reminder (Placeholder)

struct Reminder: Codable {
    // To be implemented when backend adds reminder support
}
