import SwiftUI

struct CountdownView: View {
    @StateObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Blue background
                Color(red: 0.68, green: 0.85, blue: 0.90)
                    .ignoresSafeArea()
                
                Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.fetchCountdowns() }
                    }
                } else if viewModel.countdowns.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No events yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(viewModel.countdowns) { countdown in
                        CountdownRow(countdown: countdown)
                    }
                }
            }
            .navigationTitle("Events")
            .refreshable {
                await viewModel.fetchCountdowns()
            }
        }
        .task {
            await viewModel.fetchCountdowns()
        }
    }
}

struct CountdownRow: View {
    let countdown: Countdown
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(countdown.name)
                    .font(.headline)
                
                Text(countdown.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if countdown.yearly {
                    Label("Yearly", systemImage: "repeat")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack {
                Text("\(countdown.daysLeft)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(countdown.isPast ? .gray : .blue)
                
                Text("days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
