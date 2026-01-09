import Foundation
import SwiftUI
import Combine

/// Local storage for countdowns - no backend required
/// Stores up to 20 countdowns locally using UserDefaults
class CountdownStore: ObservableObject {
    
    // MARK: - Published Properties
    @Published var countdowns: [Countdown] = []
    
    // MARK: - Constants
    private let maxCountdowns = 20
    private let storageKey = "countdowns"
    
    // MARK: - Initialization
    init() {
        load()
    }
    
    // MARK: - Public Methods
    
    /// Add a new countdown (if under limit)
    func add(_ countdown: Countdown) throws {
        guard countdowns.count < maxCountdowns else {
            throw CountdownError.limitReached
        }
        
        countdowns.append(countdown)
        save()
    }
    
    /// Update an existing countdown
    func update(_ countdown: Countdown) {
        if let index = countdowns.firstIndex(where: { $0.id == countdown.id }) {
            countdowns[index] = countdown
            save()
        }
    }
    
    /// Delete a countdown
    func delete(_ countdown: Countdown) {
        countdowns.removeAll { $0.id == countdown.id }
        save()
    }
    
    /// Delete countdown at index
    func delete(at offsets: IndexSet) {
        countdowns.remove(atOffsets: offsets)
        save()
    }
    
    /// Check if can add more countdowns
    var canAddMore: Bool {
        return countdowns.count < maxCountdowns
    }
    
    /// Remaining countdown slots
    var remainingSlots: Int {
        return maxCountdowns - countdowns.count
    }
    
    // MARK: - Private Methods
    
    private func save() {
        do {
            let encoded = try JSONEncoder().encode(countdowns)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Failed to save countdowns: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Countdown].self, from: data) else {
            // Initialize with empty array if no data
            countdowns = []
            return
        }
        
        countdowns = decoded
    }
    
    /// Clear all countdowns (useful for testing)
    func clearAll() {
        countdowns = []
        save()
    }
}

// MARK: - Errors

enum CountdownError: LocalizedError {
    case limitReached
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .limitReached:
            return "Maximum of \(20) countdowns reached. Please delete one to add more."
        case .notFound:
            return "Countdown not found."
        }
    }
}
