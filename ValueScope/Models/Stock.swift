import Foundation

/// 市场类型
enum Market: String, Codable, CaseIterable {
    case sh = "SH"  // 沪市
    case sz = "SZ"  // 深市
    case hk = "HK"  // 港股
    case us = "US"  // 美股

    var name: String {
        switch self {
        case .sh: "沪市"
        case .sz: "深市"
        case .hk: "港股"
        case .us: "美股"
        }
    }

    /// 东方财富 secid 前缀
    var eastMoneyMarketId: Int {
        switch self {
        case .sh: 1
        case .sz: 0
        case .hk: 116
        case .us: 105
        }
    }
}

/// 股票标识
struct Stock: Identifiable, Codable, Hashable {
    let symbol: String   // 代码，如 "600519", "AAPL"
    let market: Market
    let name: String

    var id: String { "\(market.rawValue).\(symbol)" }

    /// 东方财富 secid
    var secId: String { "\(market.eastMoneyMarketId).\(symbol)" }

    /// Yahoo Finance symbol
    var yahooSymbol: String {
        switch market {
        case .sh: "\(symbol).SS"
        case .sz: "\(symbol).SZ"
        case .hk: String(format: "%04d.HK", Int(symbol) ?? 0)
        case .us: symbol
        }
    }
}
