import Foundation
import Combine

@MainActor
class CountdownViewModel: ObservableObject {
    @Published var countdowns: [Countdown] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let countdownStore: CountdownStore
    
    init(countdownStore: CountdownStore) {
        self.countdownStore = countdownStore
        self.countdowns = countdownStore.countdowns
        
        // Observe changes from store
        countdownStore.$countdowns
            .assign(to: &$countdowns)
    }
    
    func fetchCountdowns() async {
        // Data is already loaded from local storage
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
