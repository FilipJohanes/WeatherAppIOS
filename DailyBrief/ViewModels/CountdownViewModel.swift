import Foundation
import Combine

@MainActor
class CountdownViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var countdowns: [Countdown] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    // FIX: Changed from 'let' to 'var' so it can be updated via the View
    private var countdownStore: CountdownStore
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(countdownStore: CountdownStore) {
        self.countdownStore = countdownStore
        self.countdowns = countdownStore.countdowns
        setupSync()
    }
    
    // FIX: Added the missing function the View is trying to call
    func updateStore(_ store: CountdownStore) {
        self.countdownStore = store
        setupSync()
    }
    
    private func setupSync() {
        // Clear previous subscriptions
        cancellables.removeAll()
        
        // Auto-sync with store changes
        countdownStore.$countdowns
            .assign(to: &$countdowns)
    }
    
    // MARK: - Public Methods
    
    func fetchCountdowns() async {
        countdowns = countdownStore.countdowns
    }
    
    func add(_ countdown: Countdown) {
        do {
            try countdownStore.add(countdown)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func update(_ countdown: Countdown) {
        countdownStore.update(countdown)
        errorMessage = nil
    }
    
    func delete(_ countdown: Countdown) {
        countdownStore.delete(countdown)
        errorMessage = nil
    }
    
    func delete(at offsets: IndexSet) {
        countdownStore.delete(at: offsets)
        errorMessage = nil
    }
    
    var canAddMore: Bool {
        return countdownStore.canAddMore
    }
    
    var remainingSlots: Int {
        return countdownStore.remainingSlots
    }
}
