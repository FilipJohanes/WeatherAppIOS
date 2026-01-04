import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case serverError(String)
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to parse data: \(error.localizedDescription)"
        case .unauthorized:
            return "Please login again"
        case .serverError(let message):
            return message
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        }
    }
}

class APIService: ObservableObject {
    static let shared = APIService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private var jwtToken: String? {
        didSet {
            isAuthenticated = jwtToken != nil
            if let token = jwtToken {
                KeychainHelper.shared.save(token, for: "jwt_token")
            } else {
                KeychainHelper.shared.delete("jwt_token")
            }
        }
    }
    
    private init() {
        // Load token from keychain on init
        jwtToken = KeychainHelper.shared.get("jwt_token")
        isAuthenticated = jwtToken != nil
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(APIConfig.baseURL)/api/users/authenticate") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = AuthenticationRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimitExceeded
            }
            
            let authResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
            
            if authResponse.success {
                jwtToken = authResponse.token
                currentUser = authResponse.user
                return authResponse.user
            } else {
                throw APIError.serverError("Authentication failed")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func logout() {
        jwtToken = nil
        currentUser = nil
    }
    
    // MARK: - Data Fetching
    
    func getDailyBrief() async throws -> DailyBrief {
        guard let token = jwtToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/v2/daily-brief") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                logout()
                throw APIError.unauthorized
            }
            
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimitExceeded
            }
            
            let apiResponse = try JSONDecoder().decode(APIResponse<DailyBrief>.self, from: data)
            
            if apiResponse.success, let brief = apiResponse.data {
                return brief
            } else {
                throw APIError.serverError(apiResponse.error ?? "Unknown error")
            }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getWeather() async throws -> Weather {
        guard let token = jwtToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/v2/weather") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            logout()
            throw APIError.unauthorized
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<Weather>.self, from: data)
        
        if apiResponse.success, let weather = apiResponse.data {
            return weather
        } else {
            throw APIError.serverError(apiResponse.error ?? "Failed to fetch weather")
        }
    }
    
    func getCountdowns() async throws -> [Countdown] {
        guard let token = jwtToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/v2/countdowns") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            logout()
            throw APIError.unauthorized
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<[Countdown]>.self, from: data)
        
        if apiResponse.success, let countdowns = apiResponse.data {
            return countdowns
        } else {
            throw APIError.serverError(apiResponse.error ?? "Failed to fetch countdowns")
        }
    }
    
    func getNameday() async throws -> Nameday? {
        guard let token = jwtToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/api/v2/nameday") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            logout()
            throw APIError.unauthorized
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<Nameday?>.self, from: data)
        
        return apiResponse.data
    }
}
