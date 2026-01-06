import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Blue background matching the Trident branding
            Color(red: 0.68, green: 0.85, blue: 0.90)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Trident logo
                Image("TridentLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("TRIDENT")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
