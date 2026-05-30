import Foundation

/// 估值数据
struct Valuation: Identifiable, Codable {
    let symbol: String
    let market: String
    let name: String
    let pe: Double?          // 市盈率
    let pb: Double?          // 市净率
    let roe: Double?         // ROE %
    let dividendYield: Double? // 股息率 %
    let marketCap: Double?   // 总市值（亿）
    let pePercentile: Double?  // PE 历史百分位
    let pbPercentile: Double?  // PB 历史百分位
    let updateDate: String

    var id: String { "\(market).\(symbol)" }

    var valuationLevel: ValuationLevel {
        guard let pePct = pePercentile else { return .normal }
        if pePct < 30 { return .undervalued }
        if pePct > 70 { return .overvalued }
        return .normal
    }
}

enum ValuationLevel: String {
    case undervalued = "低估"
    case normal = "正常"
    case overvalued = "高估"

    var color: String {
        switch self {
        case .undervalued: "green"
        case .normal: "orange"
        case .overvalued: "red"
        }
    }
}
