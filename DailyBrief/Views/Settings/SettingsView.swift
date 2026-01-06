import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                Form {
                if let user = apiService.currentUser {
                    Section("Account") {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Timezone")
                            Spacer()
                            Text(user.timezone)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Logout", role: .destructive) {
                        apiService.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
