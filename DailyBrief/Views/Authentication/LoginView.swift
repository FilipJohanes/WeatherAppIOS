import SwiftUI

struct LoginView: View {
    @EnvironmentObject var apiService: APIService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("DailyBrief")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Spacer()
            }
            .padding()
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
