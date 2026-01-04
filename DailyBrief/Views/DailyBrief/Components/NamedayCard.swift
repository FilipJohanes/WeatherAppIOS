import SwiftUI

struct NamedayCard: View {
    let nameday: Nameday
    
    var body: some View {
        HStack {
            Image(systemName: "gift.fill")
                .font(.title2)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading) {
                Text("Name Day")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(nameday.names)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
