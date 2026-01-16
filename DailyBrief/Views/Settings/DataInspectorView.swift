import SwiftUI

/// DataInspectorView: Debug view to inspect stored location and weather data
/// 
/// **Purpose:**
/// - Show all tracked locations with their coordinates
/// - Display cached weather data for each location
/// - Verify API calls are using correct coordinates
/// - Export data for debugging
/// 
/// **How to use:**
/// Add this view to your Settings or as a debug menu item
struct DataInspectorView: View {
    @ObservedObject var weatherStore: WeatherStore
    @State private var showingExport = false
    @State private var exportedData = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tracked Locations (\(weatherStore.trackedLocations.count)/10)")) {
                    ForEach(weatherStore.trackedLocations) { location in
                        LocationDetailRow(location: location, weatherStore: weatherStore)
                    }
                }
                
                Section(header: Text("Weather Cache")) {
                    Text("Cached items: \(weatherStore.weatherCache.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(weatherStore.weatherCache.keys), id: \.self) { locationId in
                        if let weather = weatherStore.weatherCache[locationId],
                           let location = weatherStore.trackedLocations.first(where: { $0.id == locationId }) {
                            CacheDetailRow(location: location, weather: weather)
                        }
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button(action: exportData) {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: clearCache) {
                        Label("Clear Weather Cache", systemImage: "trash")
                    }
                    .foregroundColor(.orange)
                    
                    Button(action: clearAllData) {
                        Label("Clear All Data", systemImage: "exclamationmark.triangle")
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Data Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingExport) {
                ExportView(data: exportedData)
            }
        }
    }
    
    private func exportData() {
        var output = "=== TRACKED LOCATIONS ===\n\n"
        
        for (index, location) in weatherStore.trackedLocations.enumerated() {
            output += "[\(index + 1)] \(location.displayName)\n"
            output += "  ID: \(location.id)\n"
            output += "  Type: \(location.isCurrentLocation ? "Current Location" : "Manual")\n"
            output += "  Coordinates: (\(location.latitude ?? 0), \(location.longitude ?? 0))\n"
            output += "  Selected for Home: \(location.isSelectedForHome)\n"
            output += "  Date Added: \(location.dateAdded)\n"
            
            if let weather = weatherStore.weatherCache[location.id] {
                output += "  ✅ Weather Cached:\n"
                output += "     Location: \(weather.location)\n"
                output += "     Temperature: \(weather.currentTemp)°C\n"
                output += "     Condition: \(weather.condition.rawValue)\n"
            } else {
                output += "  ⚠️ No cached weather\n"
            }
            
            output += "\n"
        }
        
        output += "\n=== WEATHER CACHE ===\n\n"
        output += "Total cached items: \(weatherStore.weatherCache.count)\n\n"
        
        for (locationId, weather) in weatherStore.weatherCache {
            if let location = weatherStore.trackedLocations.first(where: { $0.id == locationId }) {
                output += "Location: \(location.displayName)\n"
                output += "  Weather location: \(weather.location)\n"
                output += "  Temperature: \(weather.currentTemp)°C\n"
                output += "  Feels Like: \(weather.feelsLike)°C\n"
                output += "  Humidity: \(weather.humidity)%\n"
                output += "  Wind Speed: \(weather.windSpeed) km/h\n"
                output += "  Condition: \(weather.condition.weatherEmoji) \(weather.condition.rawValue)\n"
                output += "\n"
            }
        }
        
        exportedData = output
        showingExport = true
    }
    
    private func clearCache() {
        weatherStore.clearWeatherCache()
    }
    
    private func clearAllData() {
        weatherStore.clearAll()
    }
}

struct LocationDetailRow: View {
    let location: TrackedLocation
    let weatherStore: WeatherStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(location.displayName)
                    .font(.headline)
                
                if location.isCurrentLocation {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if location.isSelectedForHome {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Text("ID: \(location.id.uuidString)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let lat = location.latitude, let lon = location.longitude {
                Text("📍 (\(String(format: "%.4f", lat)), \(String(format: "%.4f", lon)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("📍 No coordinates")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if let weather = weatherStore.weatherCache[location.id] {
                HStack {
                    Text("✅ Cached:")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("\(weather.location) - \(String(format: "%.1f", weather.currentTemp))°C")
                        .font(.caption)
                }
            } else {
                Text("⚠️ No cached weather")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CacheDetailRow: View {
    let location: TrackedLocation
    let weather: Weather
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.displayName)
                .font(.headline)
            
            HStack {
                Text("API Location:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(weather.location)
                    .font(.caption)
                    .foregroundColor(location.displayName == weather.location ? .green : .orange)
            }
            
            HStack {
                Text("📍")
                Text("(\(String(format: "%.4f", location.latitude ?? 0)), \(String(format: "%.4f", location.longitude ?? 0)))")
                    .font(.caption)
            }
            
            HStack {
                Text("\(weather.condition.weatherEmoji) \(String(format: "%.1f", weather.currentTemp))°C")
                    .font(.caption)
                Spacer()
                Text("Feels \(String(format: "%.1f", weather.feelsLike))°C")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    let data: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(data)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Exported Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: copyToClipboard) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = data
        #endif
    }
}

#Preview {
    let weatherStore = WeatherStore()
    DataInspectorView(weatherStore: weatherStore)
}
