import Foundation

class CacheManager {
    static let shared = CacheManager()
    private init() {}
    
    func saveDailyBrief(_ brief: DailyBrief) {
        if let encoded = try? JSONEncoder().encode(brief) {
            UserDefaults.standard.set(encoded, forKey: "cached_daily_brief")
        }
    }
    
    func loadDailyBrief() -> DailyBrief? {
        guard let data = UserDefaults.standard.data(forKey: "cached_daily_brief"),
              let brief = try? JSONDecoder().decode(DailyBrief.self, from: data) else {
            return nil
        }
        return brief
    }
    
    func saveWeather(_ weather: Weather) {
        if let encoded = try? JSONEncoder().encode(weather) {
            UserDefaults.standard.set(encoded, forKey: "cached_weather")
        }
    }
    
    func loadWeather() -> Weather? {
        guard let data = UserDefaults.standard.data(forKey: "cached_weather"),
              let weather = try? JSONDecoder().decode(Weather.self, from: data) else {
            return nil
        }
        return weather
    }
    
    func saveCountdowns(_ countdowns: [Countdown]) {
        if let encoded = try? JSONEncoder().encode(countdowns) {
            UserDefaults.standard.set(encoded, forKey: "cached_countdowns")
        }
    }
    
    func loadCountdowns() -> [Countdown]? {
        guard let data = UserDefaults.standard.data(forKey: "cached_countdowns"),
              let countdowns = try? JSONDecoder().decode([Countdown].self, from: data) else {
            return nil
        }
        return countdowns
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: "cached_daily_brief")
        UserDefaults.standard.removeObject(forKey: "cached_weather")
        UserDefaults.standard.removeObject(forKey: "cached_countdowns")
    }
}
