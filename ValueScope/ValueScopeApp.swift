import SwiftUI
import SwiftData

@main
struct ValueScopeApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [WatchlistItem.self, CachedQuote.self])
    }
}
