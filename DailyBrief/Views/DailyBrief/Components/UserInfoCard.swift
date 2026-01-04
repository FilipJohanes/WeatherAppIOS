import SwiftUI

struct UserInfoCard: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hello, \(user.nickname ?? user.username)! 👋")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "clock")
                Text(user.timezone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
