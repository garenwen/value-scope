import Foundation

/// 实时报价
struct Quote: Identifiable {
    let stock: Stock
    let price: Double
    let change: Double       // 涨跌额
    let changePercent: Double // 涨跌幅 %
    let open: Double
    let high: Double
    let low: Double
    let volume: Double       // 成交量（手）
    let amount: Double       // 成交额
    let timestamp: Date

    var id: String { stock.id }
    var isUp: Bool { change >= 0 }
}
