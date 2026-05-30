import Foundation

/// 估值分析 ViewModel
@MainActor
@Observable
class ValuationViewModel {
    var valuations: [Valuation] = []
    var selectedMarket: Market = .sh
    var isLoading = false
    var error: String?

    private let repository = StockRepository.shared

    func load() {
        Task {
            isLoading = true
            error = nil
            do {
                valuations = try await repository.fetchValuations(market: selectedMarket)
            } catch {
                self.error = "加载估值数据失败"
            }
            isLoading = false
        }
    }

    var undervalued: [Valuation] {
        valuations.filter { $0.valuationLevel == .undervalued }
    }

    var overvalued: [Valuation] {
        valuations.filter { $0.valuationLevel == .overvalued }
    }
}
