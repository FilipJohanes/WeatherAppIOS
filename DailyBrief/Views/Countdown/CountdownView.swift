import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var countdownStore: CountdownStore
    @StateObject private var viewModel: CountdownViewModel
    @State private var showingAddCountdown = false
    
    init() {
        // Initialize with a placeholder; updated in .onAppear
        _viewModel = StateObject(wrappedValue: CountdownViewModel(
            countdownStore: CountdownStore()
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
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
                        emptyStateView
                    } else {
                        countdownList
                    }
                }
                .navigationTitle("Events (\(viewModel.countdowns.count)/20)")
                .toolbar {
                    if viewModel.canAddMore {
                        Button(action: { showingAddCountdown = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddCountdown) {
                    AddCountdownView(viewModel: viewModel)
                }
                .refreshable {
                    await viewModel.fetchCountdowns()
                }
                .onAppear {
                    // Sync with the actual environment store
                    viewModel.updateStore(countdownStore)
                    Task {
                        await viewModel.fetchCountdowns()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No events yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddCountdown = true }) {
                Text("Add Your First Event")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                    .cornerRadius(10)
            }
        }
    }
    
    private var countdownList: some View {
        List {
            ForEach(viewModel.countdowns) { countdown in
                CountdownRow(countdown: countdown)
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - AddCountdownView
struct AddCountdownView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CountdownViewModel
    
    @State private var name = ""
    @State private var date = Date()
    @State private var yearly = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Yearly", isOn: $yearly)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCountdown()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addCountdown() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let days = calculateDaysLeft()
        let newCountdown = Countdown(
            name: name,
            date: formatter.string(from: date),
            yearly: yearly,
            daysLeft: days,
            nextOccurrence: formatter.string(from: date),
            isPast: date < Calendar.current.startOfDay(for: Date()),
            message: days == 0 ? "Today!" : "\(days) days"
        )
        
        viewModel.add(newCountdown)
        if viewModel.errorMessage == nil { dismiss() }
    }
    
    private func calculateDaysLeft() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
}

// MARK: - CountdownRow
struct CountdownRow: View {
    let countdown: Countdown
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(countdown.name).font(.headline)
                Text(countdown.date).font(.caption).foregroundColor(.secondary)
                if countdown.yearly {
                    Label("Yearly", systemImage: "repeat").font(.caption2).foregroundColor(.blue)
                }
            }
            Spacer()
            VStack {
                Text("\(countdown.daysLeft)")
                    .font(.title).fontWeight(.bold)
                    .foregroundColor(countdown.isPast ? .gray : .blue)
                Text("days").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
