import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var presetStore: WeatherPresetStore
    @EnvironmentObject var weatherStore: WeatherStore
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                Form {
                    // Weather Configuration Section
                    Section("Weather Configuration") {
                        NavigationLink(destination: WeatherPresetSettingsView(presetStore: presetStore)) {
                            HStack {
                                Label("Weather Data", systemImage: "cloud.sun")
                                Spacer()
                                Text(presetDescription)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        
                        HStack {
                            Text("Enabled Parameters")
                            Spacer()
                            Text("\(presetStore.preset.enabledCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Forecast Days")
                            Spacer()
                            Text("\(presetStore.preset.forecastDays)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Debug Tools Section
                    Section("Debug Tools") {
                        NavigationLink(destination: DataInspectorView(weatherStore: weatherStore)) {
                            Label("Data Inspector", systemImage: "doc.text.magnifyingglass")
                        }
                    }
                    
                    Section("App Information") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Stage")
                            Spacer()
                            Text("MVP (Stage 1)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Features") {
                        HStack {
                            Text("Countdown Limit")
                            Spacer()
                            Text("20 events")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Weather Cache")
                            Spacer()
                            Text("30 minutes")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("About") {
                        Link("Weather data by Open-Meteo", 
                             destination: URL(string: "https://open-meteo.com")!)
                        
                        HStack {
                            Text("Architecture")
                            Spacer()
                            Text("Serverless")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("API Key Required")
                            Spacer()
                            Text("No ✓")
                                .foregroundColor(.green)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
    
    private var presetDescription: String {
        if presetStore.preset == .minimal {
            return "Minimal"
        } else if presetStore.preset == .standard {
            return "Standard"
        } else if presetStore.preset == .complete {
            return "Complete"
        } else {
            return "Custom"
        }
    }
}

#Preview {
    SettingsView()
