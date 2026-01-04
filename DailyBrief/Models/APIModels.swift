import Foundation

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

// MARK: - Authentication

struct AuthenticationRequest: Codable {
    let email: String
    let password: String
}

struct AuthenticationResponse: Codable {
    let success: Bool
    let user: User
    let token: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case success, user, token
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
