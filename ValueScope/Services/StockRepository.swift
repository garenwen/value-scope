import Foundation

/// 统一数据仓库，封装多数据源访问
@MainActor
class StockRepository: ObservableObject {
    static let shared = StockRepository()

    /// 获取实时报价
    func fetchQuote(for stock: Stock) async throws -> Quote {
        switch stock.market {
        case .sh, .sz, .hk:
            return try await EastMoneyAPI.fetchQuote(stock: stock)
        case .us:
            return try await YahooFinanceAPI.fetchQuote(stock: stock)
        }
    }

    /// 批量获取报价
    func fetchQuotes(for stocks: [Stock]) async -> [Quote] {
        await withTaskGroup(of: Quote?.self) { group in
            for stock in stocks {
                group.addTask { try? await self.fetchQuote(for: stock) }
            }
            var results: [Quote] = []
            for await quote in group {
                if let q = quote { results.append(q) }
            }
            return results
        }
    }

    /// 获取K线
    func fetchKLine(for stock: Stock, period: KLinePeriod) async throws -> [KLinePoint] {
        switch stock.market {
        case .sh, .sz, .hk:
            return try await EastMoneyAPI.fetchKLine(stock: stock, period: period)
        case .us:
            return try await YahooFinanceAPI.fetchKLine(stock: stock, period: period)
        }
    }

    /// 搜索股票
    func search(keyword: String) async throws -> [Stock] {
        try await EastMoneyAPI.search(keyword: keyword)
    }

    /// 获取估值数据
    func fetchValuations(market: Market) async throws -> [Valuation] {
        try await ValuationDataAPI.fetchValuations(market: market)
    }
}
