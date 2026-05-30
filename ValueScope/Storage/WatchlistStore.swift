import Foundation
import SwiftData

/// 自选股持久化模型
@Model
final class WatchlistItem {
    var symbol: String
    var marketRaw: String
    var name: String
    var sortOrder: Int
    var addedAt: Date

    init(stock: Stock, sortOrder: Int = 0) {
        self.symbol = stock.symbol
        self.marketRaw = stock.market.rawValue
        self.name = stock.name
        self.sortOrder = sortOrder
        self.addedAt = Date()
    }

    var market: Market { Market(rawValue: marketRaw) ?? .sh }
    var stock: Stock { Stock(symbol: symbol, market: market, name: name) }
}

/// 报价缓存
@Model
final class CachedQuote {
    @Attribute(.unique) var stockId: String
    var price: Double
    var change: Double
    var changePercent: Double
    var updatedAt: Date

    init(quote: Quote) {
        self.stockId = quote.stock.id
        self.price = quote.price
        self.change = quote.change
        self.changePercent = quote.changePercent
        self.updatedAt = Date()
    }
}
