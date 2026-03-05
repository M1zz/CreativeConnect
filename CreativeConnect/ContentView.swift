import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("훈련", systemImage: "brain.head.profile")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("기록", systemImage: "clock.fill")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .environmentObject(store)
        .tint(.purple)
    }
}
