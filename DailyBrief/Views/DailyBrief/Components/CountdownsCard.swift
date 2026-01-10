import SwiftUI

struct CountdownsCard: View {
    let countdowns: [Countdown]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)
            
            ForEach(countdowns) { countdown in
                HStack {
                    VStack(alignment: .leading) {
                        Text(countdown.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(countdown.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(countdown.daysLeft)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
                
                if countdown.id != countdowns.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            Color(red: 0.53, green: 0.81, blue: 0.92).opacity(0.1)  // Sky blue at 10% opacity
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 1.5)  // Thin white border
        )
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
