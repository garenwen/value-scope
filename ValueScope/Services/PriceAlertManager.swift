import Foundation
import UserNotifications

/// 价格提醒管理
@MainActor
class PriceAlertManager: ObservableObject {
    static let shared = PriceAlertManager()

    @Published var alerts: [PriceAlert] = []

    struct PriceAlert: Identifiable, Codable {
        let id: UUID
        let stock: Stock
        let targetPrice: Double
        let isAbove: Bool  // true=涨到, false=跌到

        var description: String {
            "\(stock.name) \(isAbove ? "涨到" : "跌到") \(targetPrice.priceText)"
        }
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func addAlert(stock: Stock, targetPrice: Double, isAbove: Bool) {
        let alert = PriceAlert(id: UUID(), stock: stock, targetPrice: targetPrice, isAbove: isAbove)
        alerts.append(alert)
        save()
    }

    func removeAlert(_ alert: PriceAlert) {
        alerts.removeAll { $0.id == alert.id }
        save()
    }

    /// 检查是否触发提醒
    func check(quote: Quote) {
        for alert in alerts where alert.stock.id == quote.stock.id {
            let triggered = alert.isAbove ? quote.price >= alert.targetPrice : quote.price <= alert.targetPrice
            if triggered {
                sendNotification(alert: alert, currentPrice: quote.price)
                removeAlert(alert)
            }
        }
    }

    private func sendNotification(alert: PriceAlert, currentPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "价格提醒"
        content.body = "\(alert.stock.name) 当前价格 \(currentPrice.priceText)，已\(alert.isAbove ? "涨到" : "跌到")目标价 \(alert.targetPrice.priceText)"
        content.sound = .default

        let request = UNNotificationRequest(identifier: alert.id.uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(data, forKey: "price_alerts")
        }
    }

    func loadSaved() {
        if let data = UserDefaults.standard.data(forKey: "price_alerts"),
           let saved = try? JSONDecoder().decode([PriceAlert].self, from: data) {
            alerts = saved
        }
    }
}
