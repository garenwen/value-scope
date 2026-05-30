import Foundation

/// K线周期
enum KLinePeriod: String, CaseIterable {
    case daily = "101"
    case weekly = "102"
    case monthly = "103"

    var label: String {
        switch self {
        case .daily: "日K"
        case .weekly: "周K"
        case .monthly: "月K"
        }
    }
}

/// K线数据点
struct KLinePoint: Identifiable {
    let date: Date
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let volume: Double

    var id: Date { date }
    var isUp: Bool { close >= open }
}
