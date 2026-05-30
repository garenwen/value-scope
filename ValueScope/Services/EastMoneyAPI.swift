import Foundation

/// 东方财富 API 适配器（A股 + 港股）
struct EastMoneyAPI {
    private static let baseURL = "https://push2.eastmoney.com/api/qt/stock/get"
    private static let klineURL = "https://push2his.eastmoney.com/api/qt/stock/kline/get"
    private static let searchURL = "https://searchapi.eastmoney.com/api/suggest/get"

    /// 获取实时报价
    static func fetchQuote(stock: Stock) async throws -> Quote {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "secid", value: stock.secId),
            URLQueryItem(name: "fields", value: "f43,f44,f45,f46,f47,f48,f57,f58,f169,f170,f171"),
            URLQueryItem(name: "ut", value: "fa5fd1943c7b386f172d6893dbfba10b"),
        ]
        let data = try await APIClient.shared.fetchData(components.url!)
        return try parseQuote(data: data, stock: stock)
    }

    /// 获取K线数据
    static func fetchKLine(stock: Stock, period: KLinePeriod, count: Int = 120) async throws -> [KLinePoint] {
        var components = URLComponents(string: klineURL)!
        components.queryItems = [
            URLQueryItem(name: "secid", value: stock.secId),
            URLQueryItem(name: "fields1", value: "f1,f2,f3,f4,f5,f6"),
            URLQueryItem(name: "fields2", value: "f51,f52,f53,f54,f55,f56"),
            URLQueryItem(name: "klt", value: period.rawValue),
            URLQueryItem(name: "fqt", value: "1"),
            URLQueryItem(name: "lmt", value: "\(count)"),
            URLQueryItem(name: "end", value: "20500101"),
            URLQueryItem(name: "ut", value: "fa5fd1943c7b386f172d6893dbfba10b"),
        ]
        let data = try await APIClient.shared.fetchData(components.url!)
        return try parseKLine(data: data)
    }

    /// 搜索股票
    static func search(keyword: String) async throws -> [Stock] {
        var components = URLComponents(string: searchURL)!
        components.queryItems = [
            URLQueryItem(name: "input", value: keyword),
            URLQueryItem(name: "type", value: "14"),
            URLQueryItem(name: "count", value: "10"),
        ]
        let data = try await APIClient.shared.fetchData(components.url!)
        return try parseSearch(data: data)
    }

    // MARK: - Parsing

    private static func parseQuote(data: Data, stock: Stock) throws -> Quote {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let d = json["data"] as? [String: Any] else {
            throw APIError.invalidData
        }
        let divisor: Double = (stock.market == .sh || stock.market == .sz) ? 100.0 : 1000.0
        let price = (d["f43"] as? Double ?? 0) / divisor
        let open = (d["f46"] as? Double ?? 0) / divisor
        let high = (d["f44"] as? Double ?? 0) / divisor
        let low = (d["f45"] as? Double ?? 0) / divisor
        let change = (d["f169"] as? Double ?? 0) / divisor
        let changePercent = (d["f170"] as? Double ?? 0) / 100.0
        let volume = d["f47"] as? Double ?? 0
        let amount = d["f48"] as? Double ?? 0

        return Quote(stock: stock, price: price, change: change, changePercent: changePercent,
                     open: open, high: high, low: low, volume: volume, amount: amount, timestamp: Date())
    }

    private static func parseKLine(data: Data) throws -> [KLinePoint] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let d = json["data"] as? [String: Any],
              let klines = d["klines"] as? [String] else {
            throw APIError.invalidData
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return klines.compactMap { line in
            let parts = line.split(separator: ",")
            guard parts.count >= 6,
                  let date = formatter.date(from: String(parts[0])) else { return nil }
            return KLinePoint(
                date: date,
                open: Double(parts[1]) ?? 0,
                close: Double(parts[2]) ?? 0,
                high: Double(parts[3]) ?? 0,
                low: Double(parts[4]) ?? 0,
                volume: Double(parts[5]) ?? 0
            )
        }
    }

    private static func parseSearch(data: Data) throws -> [Stock] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let d = json["QuotationCodeTable"] as? [String: Any],
              let list = d["Data"] as? [[String: Any]] else {
            return []
        }
        return list.compactMap { item in
            guard let code = item["Code"] as? String,
                  let name = item["Name"] as? String,
                  let marketStr = item["MktNum"] as? String else { return nil }
            let market: Market
            switch marketStr {
            case "01": market = .sh
            case "02": market = .sz
            case "03": market = .hk
            case "05": market = .us
            default: return nil
            }
            return Stock(symbol: code, market: market, name: name)
        }
    }
}
