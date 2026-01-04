import SwiftUI

struct DailyBriefView: View {
    @StateObject private var viewModel = DailyBriefViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading your daily brief...")
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error) {
                            Task {
                                await viewModel.fetchDailyBrief()
                            }
                        }
                    } else if let brief = viewModel.dailyBrief {
                        // User Info
                        UserInfoCard(user: brief.user)
                        
                        // Weather
                        if let weather = brief.weather {
                            WeatherCard(weather: weather)
                        }
                        
                        // Countdowns
                        if let countdowns = brief.countdowns, !countdowns.isEmpty {
                            CountdownsCard(countdowns: countdowns)
                        }
                        
                        // Nameday
                        if let nameday = brief.nameday {
                            NamedayCard(nameday: nameday)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Brief")
            .refreshable {
                await viewModel.fetchDailyBrief()
            }
        }
        .task {
            await viewModel.fetchDailyBrief()
        }
    }
}
