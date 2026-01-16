import SwiftUI

/// WeatherPresetSettingsView: UI for customizing weather data preferences
///
/// **Features:**
/// - Choose which weather parameters to fetch
/// - Quick presets (Minimal, Standard, Complete)
/// - See preview of enabled features
/// - Save preferences automatically
struct WeatherPresetSettingsView: View {
    @ObservedObject var presetStore: WeatherPresetStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        Form {
            // Quick Presets Section
            Section(header: Text("Quick Presets")) {
                Button(action: { presetStore.loadPreset(.minimal) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Minimal")
                                .font(.headline)
                            Text("Temperature & Condition only")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if presetStore.preset == .minimal {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: { presetStore.loadPreset(.standard) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Standard")
                                .font(.headline)
                            Text("Essential weather data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if presetStore.preset == .standard {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: { presetStore.loadPreset(.complete) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Complete")
                                .font(.headline)
                            Text("All available data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if presetStore.preset == .complete {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            
            // Current Weather Parameters
            Section(header: Text("Current Weather"),
                    footer: Text("Data shown for current conditions")) {
                
                Toggle("Temperature", isOn: $presetStore.preset.includeTemperature)
                    .disabled(true) // Always required
                
                Toggle("Feels Like Temperature", isOn: $presetStore.preset.includeFeelsLike)
                
                Toggle("Humidity", isOn: $presetStore.preset.includeHumidity)
                
                Toggle("Weather Condition", isOn: $presetStore.preset.includeWeatherCode)
                    .disabled(true) // Always required
            }
            
            // Wind Parameters
            Section(header: Text("Wind Information")) {
                Toggle("Wind Speed", isOn: $presetStore.preset.includeWindSpeed)
                
                Toggle("Wind Direction", isOn: $presetStore.preset.includeWindDirection)
                    .disabled(!presetStore.preset.includeWindSpeed)
                
                Toggle("Wind Gusts", isOn: $presetStore.preset.includeWindGusts)
                    .disabled(!presetStore.preset.includeWindSpeed)
            }
            
            // Precipitation Parameters
            Section(header: Text("Precipitation"),
                    footer: Text("Rain, snow, and precipitation forecasts")) {
                
                Toggle("Total Precipitation", isOn: $presetStore.preset.includePrecipitation)
                
                Toggle("Precipitation Probability", isOn: $presetStore.preset.includePrecipitationProb)
                
                Toggle("Rain Amount", isOn: $presetStore.preset.includeRain)
                
                Toggle("Snowfall Amount", isOn: $presetStore.preset.includeSnow)
            }
            
            // Atmospheric Parameters
            Section(header: Text("Atmospheric Data"),
                    footer: Text("Additional atmospheric measurements")) {
                
                Toggle("Air Pressure", isOn: $presetStore.preset.includePressure)
                
                Toggle("Visibility", isOn: $presetStore.preset.includeVisibility)
                
                Toggle("Cloud Cover", isOn: $presetStore.preset.includeCloudCover)
                
                Toggle("UV Index", isOn: $presetStore.preset.includeUVIndex)
            }
            
            // Forecast Settings
            Section(header: Text("Forecast"),
                    footer: Text("Multi-day weather forecast")) {
                
                Toggle("Daily Forecast", isOn: $presetStore.preset.includeDailyForecast)
                
                if presetStore.preset.includeDailyForecast {
                    Stepper("Forecast Days: \(presetStore.preset.forecastDays)",
                            value: $presetStore.preset.forecastDays,
                            in: 1...16)
                }
            }
            
            // Summary Section
            Section(header: Text("Current Configuration")) {
                HStack {
                    Text("Enabled Features")
                    Spacer()
                    Text("\(presetStore.preset.enabledCount)")
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Parameters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(presetStore.preset.enabledFeaturesDescription)
                        .font(.caption)
                }
            }
            
            // Reset Section
            Section {
                Button(action: { showResetConfirmation = true }) {
                    HStack {
                        Spacer()
                        Text("Reset to Default")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Weather Data")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset to Default?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                presetStore.resetToDefault()
            }
        } message: {
            Text("This will restore the standard weather preset settings.")
        }
    }
}

#Preview {
    NavigationView {
        WeatherPresetSettingsView(presetStore: WeatherPresetStore())
    }
}
