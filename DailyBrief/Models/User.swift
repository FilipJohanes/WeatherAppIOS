import Foundation

struct User: Codable, Identifiable {
    let email: String
    let username: String
    let nickname: String?
    let timezone: String
    let language: String
    let personality: String
    
    var id: String { email }
}
