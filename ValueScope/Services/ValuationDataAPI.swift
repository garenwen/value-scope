import Foundation

/// GitHub Pages 估值数据 API
struct ValuationDataAPI {
    // 替换为你的 GitHub Pages 地址
    private static let baseURL = "https://garenwen.github.io/value-scope/valuation"

    static func fetchValuations(market: Market) async throws -> [Valuation] {
        let file: String
        switch market {
        case .sh, .sz: file = "a-share.json"
        case .hk: file = "hk-share.json"
        case .us: file = "us-share.json"
        }
        let url = URL(string: "\(baseURL)/\(file)")!
        return try await APIClient.shared.fetch(url, type: [Valuation].self)
    }

    static func fetchAllValuations() async throws -> [Valuation] {
        async let a = fetchValuations(market: .sh)
        async let hk = fetchValuations(market: .hk)
        async let us = fetchValuations(market: .us)
        return try await a + hk + us
    }
}
