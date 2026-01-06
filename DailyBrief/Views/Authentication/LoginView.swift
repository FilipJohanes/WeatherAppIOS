import SwiftUI

struct LoginView: View {
    @EnvironmentObject var apiService: APIService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Trident logo
                    Image("TridentLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("Trident")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))
                    
                    Spacer().frame(height: 40)
                
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                    }
                    .padding(.horizontal)
                
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
        }
    }
    
    private func login() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                _ = try await apiService.login(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
