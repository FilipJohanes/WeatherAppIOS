import Foundation
import Combine


/// WeatherPresetStore: Manages user's weather preset preferences
class WeatherPresetStore: ObservableObject {
    @Published var preset: WeatherPreset {
        didSet {
            save()
        }
    }
    
    private let storageKey = "weatherPreset"
    
    init() {
        // Load saved preset or use default
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(WeatherPreset.self, from: data) {
            self.preset = decoded
        } else {
            self.preset = .standard
        }
    }
    
    /// Save preset to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(preset) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            print("💾 [WeatherPresetStore] Saved preset: \(preset.enabledFeaturesDescription)")
        }
    }
    
    /// Load a predefined preset
    func loadPreset(_ newPreset: WeatherPreset) {
        preset = newPreset
    }
    
    /// Reset to default
    func resetToDefault() {
        preset = .standard
    }
}
