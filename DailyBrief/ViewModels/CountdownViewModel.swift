import Foundation
import Combine

/// CountdownViewModel: Manages countdown events in the app
/// 
/// **What it does:**
/// - Provides interface for Views to interact with countdown data
/// - Manages CRUD operations (Create, Read, Update, Delete)
/// - Syncs with local storage via CountdownStore
/// 
/// **How it works:**
/// - Wraps CountdownStore and exposes methods to Views
/// - Observes changes from store and publishes to UI
/// - Handles error messages for user feedback
/// 
/// **Used by:**
/// - CountdownView: Main countdown management screen
/// - DailyBriefView: Shows countdown summary on home
@MainActor
class CountdownViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// List of all countdowns (max 20)
    @Published var countdowns: [Countdown] = []
    
    /// Loading state (not used much since data is local)
    @Published var isLoading = false
    
    /// Error message when operations fail
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let countdownStore: CountdownStore
    
    // MARK: - Initialization
    
    /// Initializes with store and loads existing countdowns
    init(countdownStore: CountdownStore) {
        self.countdownStore = countdownStore
        self.countdowns = countdownStore.countdowns
        
        // Auto-sync with store changes
        countdownStore.$countdowns
            .assign(to: &$countdowns)
    }
    
    // MARK: - Public Methods
    
    /// Loads countdowns from local storage
    func fetchCountdowns() async {
        // Data is already loaded from local storage
        countdowns = countdownStore.countdowns
    }
    
    /// Adds a new countdown (max 20 total)
    func add(_ countdown: Countdown) {
        do {
            try countdownStore.add(countdown)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Updates an existing countdown
    func update(_ countdown: Countdown) {
        countdownStore.update(countdown)
        errorMessage = nil
    }
    
    /// Deletes a countdown by object
    func delete(_ countdown: Countdown) {
        countdownStore.delete(countdown)
        errorMessage = nil
    }
    
    /// Deletes countdown(s) at specified index positions
    func delete(at offsets: IndexSet) {
        countdownStore.delete(at: offsets)
        errorMessage = nil
    }
    
    /// Returns true if user can add more countdowns
    var canAddMore: Bool {
        return countdownStore.canAddMore
    }
    
    /// Number of countdown slots remaining (out of 20)
    var remainingSlots: Int {
        return countdownStore.remainingSlots
    }
}
