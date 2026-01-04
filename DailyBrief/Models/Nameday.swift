import Foundation

struct Nameday: Codable {
    let date: String
    let dayName: String
    let names: String
    let message: String
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case date, names, message, language
        case dayName = "day_name"
    }
}
