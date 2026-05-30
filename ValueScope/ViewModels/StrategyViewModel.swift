import Foundation

/// 选股策略
enum Strategy: String, CaseIterable, Identifiable {
    case lowPE = "低估值"
    case highDividend = "高股息"
    case highROE = "高ROE"
    case growth = "成长型"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .lowPE: "PE百分位 < 30%，PB百分位 < 30%"
        case .highDividend: "股息率 > 3%"
        case .highROE: "ROE > 15%"
        case .growth: "ROE > 15% 且 PE百分位 < 50%"
        }
    }

    func filter(_ v: Valuation) -> Bool {
        switch self {
        case .lowPE:
            return (v.pePercentile ?? 100) < 30 && (v.pbPercentile ?? 100) < 30
        case .highDividend:
            return (v.dividendYield ?? 0) > 3
        case .highROE:
            return (v.roe ?? 0) > 15
        case .growth:
            return (v.roe ?? 0) > 15 && (v.pePercentile ?? 100) < 50
        }
    }
}

/// 策略 ViewModel
@MainActor
@Observable
class StrategyViewModel {
    var allValuations: [Valuation] = []
    var selectedStrategy: Strategy = .lowPE
    var isLoading = false

    var results: [Valuation] {
        allValuations.filter(selectedStrategy.filter)
    }

    func load() {
        Task {
            isLoading = true
            allValuations = (try? await ValuationDataAPI.fetchAllValuations()) ?? []
            isLoading = false
        }
    }
}
