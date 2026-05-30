import Foundation
import SwiftData
import SwiftUI

/// 自选股 ViewModel
@MainActor
@Observable
class WatchlistViewModel {
    var quotes: [Quote] = []
    var isLoading = false
    var error: String?

    private let repository = StockRepository.shared
    private var refreshTask: Task<Void, Never>?

    func loadQuotes(items: [WatchlistItem]) {
        refreshTask?.cancel()
        refreshTask = Task {
            isLoading = true
            error = nil
            let stocks = items.sorted(by: { $0.sortOrder < $1.sortOrder }).map(\.stock)
            quotes = await repository.fetchQuotes(for: stocks)
            if quotes.isEmpty && !stocks.isEmpty {
                error = "获取行情失败，请检查网络"
            }
            isLoading = false
        }
    }

    /// 定时刷新
    func startAutoRefresh(items: [WatchlistItem], interval: TimeInterval = 10) {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                loadQuotes(items: items)
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
    }
}
