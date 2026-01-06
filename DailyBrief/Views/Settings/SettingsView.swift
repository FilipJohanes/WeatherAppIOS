import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                Form {
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
}
