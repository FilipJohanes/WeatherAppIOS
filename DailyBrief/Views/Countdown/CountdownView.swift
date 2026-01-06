import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var countdownStore: CountdownStore
    
    @StateObject private var viewModel: CountdownViewModel
    @State private var showingAddCountdown = false
    
    init() {
        _viewModel = StateObject(wrappedValue: CountdownViewModel(
            countdownStore: CountdownStore()
        ))
    }
    
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
                        
                        Button(action: { showingAddCountdown = true }) {
                            Text("Add Your First Event")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                                .cornerRadius(10)
                        }
                    }
                } else {
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
        }
        .onAppear {
            let newViewModel = CountdownViewModel(countdownStore: countdownStore)
            _viewModel.wrappedValue = newViewModel
            
            Task {
                await viewModel.fetchCountdowns()
            }
        }
    }
}

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
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let countdown = Countdown(
            id: UUID().uuidString,
            name: name,
            date: dateFormatter.string(from: date),
            yearly: yearly,
            daysLeft: calculateDaysLeft(),
            isPast: date < Date()
        )
        
        viewModel.add(countdown)
        
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
    
    private func calculateDaysLeft() -> Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let eventDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: now, to: eventDate)
        return components.day ?? 0
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
