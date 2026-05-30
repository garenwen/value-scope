import Foundation

/// 股票详情/报价 ViewModel
@MainActor
@Observable
class QuoteViewModel {
    var quote: Quote?
    var klineData: [KLinePoint] = []
    var selectedPeriod: KLinePeriod = .daily
    var isLoading = false

    private let repository = StockRepository.shared

    func load(stock: Stock) {
        Task {
            isLoading = true
            async let q = repository.fetchQuote(for: stock)
            async let k = repository.fetchKLine(for: stock, period: selectedPeriod)
            quote = try? await q
            klineData = (try? await k) ?? []
            isLoading = false
        }
    }

    func changePeriod(_ period: KLinePeriod, stock: Stock) {
        selectedPeriod = period
        Task {
            klineData = (try? await repository.fetchKLine(for: stock, period: period)) ?? []
        }
    }
}
