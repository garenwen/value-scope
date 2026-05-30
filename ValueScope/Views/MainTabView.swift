import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WatchlistView()
                .tabItem {
                    Label("自选", systemImage: "star.fill")
                }
            ValuationDashboard()
                .tabItem {
                    Label("估值", systemImage: "chart.bar.fill")
                }
            StrategyListView()
                .tabItem {
                    Label("策略", systemImage: "lightbulb.fill")
                }
        }
        .tint(.red)
    }
}
