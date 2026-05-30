import WidgetKit
import SwiftUI

/// Widget 数据 Timeline Provider
struct StockWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StockWidgetEntry {
        StockWidgetEntry(date: Date(), stocks: [
            .init(name: "贵州茅台", price: "1800.00", change: "+1.25%", isUp: true),
            .init(name: "腾讯控股", price: "380.00", change: "-0.53%", isUp: false),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (StockWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StockWidgetEntry>) -> Void) {
        // 实际实现中从 App Group 共享数据读取
        let entry = placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct StockWidgetEntry: TimelineEntry {
    let date: Date
    let stocks: [WidgetStock]
}

struct WidgetStock: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let change: String
    let isUp: Bool
}

/// Widget 视图
struct StockWidgetView: View {
    let entry: StockWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("自选股").font(.caption).foregroundStyle(.secondary)
            ForEach(entry.stocks) { stock in
                HStack {
                    Text(stock.name).font(.caption).lineLimit(1)
                    Spacer()
                    Text(stock.price).font(.caption).bold()
                    Text(stock.change)
                        .font(.caption2)
                        .foregroundStyle(stock.isUp ? .red : .green)
                }
            }
        }
        .padding()
    }
}

// Widget 配置（需要在单独的 Widget Extension Target 中注册）
// @main
// struct ValueScopeWidget: Widget {
//     var body: some WidgetConfiguration {
//         StaticConfiguration(kind: "ValueScopeWidget", provider: StockWidgetProvider()) { entry in
//             StockWidgetView(entry: entry)
//         }
//         .configurationDisplayName("自选股")
//         .description("实时查看自选股价格")
//         .supportedFamilies([.systemSmall, .systemMedium])
//     }
// }
