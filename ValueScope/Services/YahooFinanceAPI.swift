import Foundation

/// Yahoo Finance API 适配器（美股）
struct YahooFinanceAPI {
    private static let baseURL = "https://query1.finance.yahoo.com/v8/finance/chart"

    /// 获取实时报价
    static func fetchQuote(stock: Stock) async throws -> Quote {
        let url = URL(string: "\(baseURL)/\(stock.yahooSymbol)?interval=1d&range=1d")!
        let data = try await APIClient.shared.fetchData(url)
        return try parseQuote(data: data, stock: stock)
    }

    /// 获取K线数据
    static func fetchKLine(stock: Stock, period: KLinePeriod, count: Int = 120) async throws -> [KLinePoint] {
        let interval: String
        let range: String
        switch period {
        case .daily: interval = "1d"; range = "6mo"
        case .weekly: interval = "1wk"; range = "2y"
        case .monthly: interval = "1mo"; range = "5y"
        }
        let url = URL(string: "\(baseURL)/\(stock.yahooSymbol)?interval=\(interval)&range=\(range)")!
        let data = try await APIClient.shared.fetchData(url)
        return try parseKLine(data: data)
    }

    // MARK: - Parsing

    private static func parseQuote(data: Data, stock: Stock) throws -> Quote {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let chart = json["chart"] as? [String: Any],
              let results = chart["result"] as? [[String: Any]],
              let result = results.first,
              let meta = result["meta"] as? [String: Any] else {
            throw APIError.invalidData
        }
        let price = meta["regularMarketPrice"] as? Double ?? 0
        let prevClose = meta["chartPreviousClose"] as? Double ?? price
        let change = price - prevClose
        let changePct = prevClose > 0 ? (change / prevClose) * 100 : 0

        return Quote(stock: stock, price: price, change: change, changePercent: changePct,
                     open: price, high: price, low: price, volume: 0, amount: 0, timestamp: Date())
    }

    private static func parseKLine(data: Data) throws -> [KLinePoint] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let chart = json["chart"] as? [String: Any],
              let results = chart["result"] as? [[String: Any]],
              let result = results.first,
              let timestamps = result["timestamp"] as? [Double],
              let indicators = result["indicators"] as? [String: Any],
              let quotes = (indicators["quote"] as? [[String: Any]])?.first else {
            throw APIError.invalidData
        }
        let opens = quotes["open"] as? [Double?] ?? []
        let closes = quotes["close"] as? [Double?] ?? []
        let highs = quotes["high"] as? [Double?] ?? []
        let lows = quotes["low"] as? [Double?] ?? []
        let volumes = quotes["volume"] as? [Double?] ?? []

        return timestamps.enumerated().compactMap { i, ts in
            guard let o = opens[safe: i] ?? nil,
                  let c = closes[safe: i] ?? nil,
                  let h = highs[safe: i] ?? nil,
                  let l = lows[safe: i] ?? nil else { return nil }
            return KLinePoint(
                date: Date(timeIntervalSince1970: ts),
                open: o, close: c, high: h, low: l,
                volume: volumes[safe: i] ?? nil ?? 0
            )
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
